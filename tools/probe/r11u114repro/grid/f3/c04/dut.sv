// two-hop: unpacked-array params (vector and packed-struct elements) and a packed-array typedef concat
package pa;
  typedef struct packed { logic lock; logic [1:0] mode; } cfg_t;
  typedef logic [3:0][1:0] perm_t;
  parameter cfg_t CfgRst[2] = '{ '{lock: 1'b0, mode: 2'b01}, '{lock: 1'b1, mode: 2'b10} };
  parameter logic [7:0] AddrRst[2] = '{ 8'h0, 8'h1 };
  parameter perm_t PermDef = { 8'hA5 };
  localparam cfg_t OneCfg = '{lock: 1'b1, mode: 2'b11};
endpackage
package pb;
  import pa::*;
  parameter int B_W = 3;
endpackage
module top (input logic [31:0] x, output logic y);
  import pb::*;
  assign y = x[0];
endmodule
