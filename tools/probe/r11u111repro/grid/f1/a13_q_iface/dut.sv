package q;
  typedef logic [2:0] mask_t;
endpackage
interface ifc #(parameter q::mask_t M = '0) ();
  logic [2:0] v;
  assign v = M;
endinterface
module dut (output logic [2:0] o);
  ifc #(.M(3'b110)) i ();
  assign o = i.v;
endmodule
