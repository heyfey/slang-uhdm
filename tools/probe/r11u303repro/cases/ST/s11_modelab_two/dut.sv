// § genConnSelBaseNameTrim303
interface sif;
  logic v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s);
  wire w; assign w = s.v;
endmodule
module mid;
  sif dn [3:0] ();
  ileaf a (.s (dn [2]));
  ileaf b (.s (dn  [3]));
endmodule
module top;
  mid m0 ();
  mid m1 ();
endmodule
