// v54 VERIFIER ARM v4 — CONNECTION FORMS the a-grids did not use.
// POSITIONAL (ordered) connections, a MODPORT-connected child, an instance
// ARRAY with a named conn, and an INOUT port.  Each takes a different route to
// the HighConn build, and only named/scalar forms were measured.
interface ifv4_54;
  logic [7:0] bus;
  modport mp (input bus);
endinterface
module snkv4_54 (input [7:0] a, inout [7:0] io, output [7:0] o);
  assign o = ~a;
endmodule
module snkm_v4_54 (ifv4_54.mp m, input [7:0] a, output [7:0] o);
  assign o = a ^ m.bus;
endmodule
module v4_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  ifv4_54 theif();
  wire  [7:0] io1;
  logic [7:0] w1, w2, w3;
  // POSITIONAL connection carrying the nested replication
  snkv4_54   u_pos (({sel ? d[3:0] : {4{1'b0}}, 4'h1}), io1, w1);
  // MODPORT-connected child with a nested replication on a normal port
  snkm_v4_54 u_mp  (.m(theif.mp), .a({sel ? d[3:0] : {4{1'b1}}, 4'h2}), .o(w2));
  // INSTANCE ARRAY, one written conn
  snkv4_54   u_arr [1:0] (.a({sel ? d[3:0] : {4{1'b1}}, 4'h3}), .io(io1), .o());
  // INOUT actual carrying a replication is illegal; the nearest legal
  // neighbour is a replication on the input of the same instance.
  snkv4_54   u_io  (.a({ {4{1'b0}}, 4'h4 }), .io(io1), .o(w3));
  assign q = w1 ^ w2 ^ w3;
endmodule
