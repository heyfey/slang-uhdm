// § queueMemberSpanToDim212 — r11u217 q01: queue struct members with ONE, TWO and THREE unpacked dimensions (`int a[$]`, `int b[$][2]`, `byte c[$][2][3]`), a bounded queue `int d[$:7]`
module dut(input logic i, output logic o);
  typedef struct {
    int a[$];
    int b[$][2];
    byte c[$][2][3];
    int d[$:7];
  } a_t;
  a_t v;
  assign o = i;
endmodule
