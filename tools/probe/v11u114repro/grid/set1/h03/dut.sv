// face-3 break: leak of a packed-struct concat param
package pa;
  typedef struct packed {logic [3:0] a; logic [3:0] b;} s_t; parameter s_t SV = {4'h1, 4'h2};
endpackage
package pb; import pa::*; parameter logic [7:0] QB = 8'h1; endpackage
package pc; import pb::*; parameter logic [7:0] QC = 8'h2; endpackage
module top import pb::*; (output logic [7:0] o); assign o = QB; endmodule
