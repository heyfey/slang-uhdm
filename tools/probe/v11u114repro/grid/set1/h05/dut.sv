// face-3 break: leak of an array-of-struct pattern
package pa;
  typedef struct packed {logic [3:0] a; logic [3:0] b;} s_t; parameter s_t AS [2] = '{'{a: 4'h1, b: 4'h2}, '{a: 4'h3, b: 4'h4}};
endpackage
package pb; import pa::*; parameter logic [7:0] QB = 8'h1; endpackage
package pc; import pb::*; parameter logic [7:0] QC = 8'h2; endpackage
module top import pb::*; (output logic [7:0] o); assign o = QB; endmodule
