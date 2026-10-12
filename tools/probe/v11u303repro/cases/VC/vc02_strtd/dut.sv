// § classParamNamedTypeTs303
typedef string str_t;
class C #(parameter str_t S = "ab");
  string v = S;
endclass
module dut (output logic [2:0] o);
  C #() c;
  assign o = 3'b0;
endmodule
