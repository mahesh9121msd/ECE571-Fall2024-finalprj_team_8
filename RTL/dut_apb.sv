//import apb_pkg::*; // Import the package
module apb_mem (
    input logic PCLK,
    input logic PRESETn,
    apb_if.slave apb
);

    parameter RDY_COUNT = 1;
    
    import apb_pkg::*; // Import the package
	//typedef enum logic [1:0] {IDLE, SETUP, ACCESS} state_t;
    state_t State, Next;
    //logic [31:0] mem [0:1023];
    //ogic [31:0] rdata;
    //nt rdy_counter;

    // Assign outputs to the interface
    assign apb.PRDATA = rdata;

    // State transition logic
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            State <= IDLE;
        else
            State <= Next;
    end

    // Next state logic
    always_comb begin
        Next = State;
        unique case (State)
            IDLE: if (apb.PSEL) Next = SETUP;
            SETUP: if (apb.PENABLE) Next = ACCESS;
            ACCESS: if (rdy_counter == RDY_COUNT - 1) Next = IDLE;
        endcase
    end

    // Output and control signal logic
    always_comb begin
        apb.PREADY = 1'b0;
        rdata = 32'h0;
        unique case (State)
            IDLE: begin end
            SETUP: begin end
            ACCESS: begin
                apb.PREADY = (rdy_counter == RDY_COUNT - 1);
                if (!apb.PWRITE)
                    rdata = mem[apb.PADDR];
            end
        endcase
    end

    // Ready signal and counter logic
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            rdy_counter <= 0;
        else if (State == ACCESS && rdy_counter < RDY_COUNT - 1)
            rdy_counter <= rdy_counter + 1;
        else
            rdy_counter <= 0;
    end

    // Memory write logic
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            for (int i = 0; i < 1024; i++)
                mem[i] <= 32'h0000_0000;
        else if (State == ACCESS && apb.PWRITE)
            mem[apb.PADDR] <= apb.PWDATA;
    end
endmodule
