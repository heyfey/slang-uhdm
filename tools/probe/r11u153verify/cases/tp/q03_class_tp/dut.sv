// § typeParamStructAtKeyword146
class c #(type T = struct packed { logic [3:0] a; });
  T v;
endclass
module top(output logic o);
  c h;
  assign o = 1'b0;
endmodule
