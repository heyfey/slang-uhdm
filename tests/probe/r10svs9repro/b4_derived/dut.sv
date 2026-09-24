class base_pkt;
  rand int data;
endclass
// q1 derived WITH a constraint
class d_cons extends base_pkt;
  constraint c1 { data > 200; }
endclass
// q2 derived, NO constraint
class d_plain extends base_pkt;
  int extra;
endclass
// q3 NOT derived, WITH a constraint
class c_cons;
  rand int data;
  constraint c2 { data > 200; }
endclass
// q4 neither
class plain;
  int data;
endclass
program tc;
  d_cons  a1;
  d_plain a2;
  c_cons  a3;
  plain   a4;
endprogram
module top; tc TC(); endmodule
