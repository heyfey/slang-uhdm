package pd10;
  typedef bit [3:0] td_bit;
endpackage
module vdTop10;
  typedef enum pd10::td_bit { Q0 = 0, Q1 = 1 } e_qual;
  e_qual v;
endmodule
