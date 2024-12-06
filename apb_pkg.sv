

// apb_pkg.sv
package apb_pkg;

  // Internal signals
    typedef enum logic [1:0] {IDLE, SETUP, ACCESS} state_t;
    logic [31:0] mem [0:1023];
    logic [31:0] rdata;
    int rdy_counter;
	
	
endpackage 