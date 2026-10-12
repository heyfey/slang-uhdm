// § clsSpecDeclNameSpan291
class base; endclass
class reg_c #(type T = base); endclass
class hold;
  reg_c #(base) r;
endclass
module dut; hold h; initial h = new; endmodule
