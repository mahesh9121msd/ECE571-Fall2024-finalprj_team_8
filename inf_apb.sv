interface apb_if(input logic PCLK, input logic PRESETn);
    logic PSEL;
    logic [9:0] PADDR;
    logic PENABLE;
    logic PWRITE;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic PREADY;

    // Modports for master and slave
    modport master (
        output PSEL, PADDR, PENABLE, PWRITE, PWDATA,
        input PRDATA, PREADY
    );

    modport slave (
        input PSEL, PADDR, PENABLE, PWRITE, PWDATA,
        output PRDATA, PREADY
    );
endinterface
