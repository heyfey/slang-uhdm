package q;
  typedef logic [0:2] mask_t;
endpackage
class C #(parameter q::mask_t M = 3'b010);
  logic [2:0] v = M;
endclass
module dut (output logic [2:0] o);
  C #(3'b110) c;
  assign o = 3'b0;
endmodule
