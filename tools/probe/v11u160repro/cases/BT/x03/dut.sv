// § bodyTypeParamDefaultBound160
interface ifc;
  localparam type my_t = struct packed { logic [3:0] a; logic [3:0] b; };
  my_t [1:0] arr;
endinterface
module top (input logic [15:0] d, output logic [15:0] o);
  ifc i();
  assign i.arr = d;
  assign o = i.arr;
endmodule
