// v11u88 v25 -- the MODULE twin of v2: does the module home's
// substNdaParamRefs collide by NAME too?
package pk;
  typedef enum logic [3:0] { EA, EB = 2 } e_t;
  localparam int K = 5;
endpackage

module dut (output logic [31:0] o);
  localparam int EB = 9;
  localparam int K = 9;
  wire [31:0] w_e = pk::EB;
  wire [31:0] w_k = pk::K;
  assign o = w_e ^ w_k;
endmodule
