// § clsSpecDeclNameSpan291
class base; endclass
class reg_c #(type T = base, string N = "x"); endclass
class hold;
  reg_c #(base, "y") r;
endclass
module dut; hold h; initial h = new; endmodule
