package pf10;
  typedef bit [3:0] tf_bit;
  typedef tf_bit    tf_bit_c;
endpackage
class cf10 #(parameter type PT = pf10::tf_bit, parameter type PC = pf10::tf_bit_c);
  typedef enum PT { A0 = 0, A1 = 1 } e_tp;
  typedef enum PC { B0 = 0, B1 = 1 } e_tpc;
  e_tp  a;
  e_tpc b;
endclass
module vfTop10;
  cf10 #(pf10::tf_bit, pf10::tf_bit_c) h1;
  cf10 #(bit [7:0],    pf10::tf_bit)   h2;
endmodule
