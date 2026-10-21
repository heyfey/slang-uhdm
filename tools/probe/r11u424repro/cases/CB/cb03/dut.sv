// § classParamBitsKeywordFold424 (control: a typedef argument)
class C;
  typedef logic [3:0] n_t;
  localparam A = $bits(n_t);
endclass
module test;
endmodule
