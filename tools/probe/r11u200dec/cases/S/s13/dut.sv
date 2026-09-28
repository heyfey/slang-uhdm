module s13;
  task automatic t1(input int  a, output int  b); b = a; endtask
  task automatic t2(input int signed a, output int signed b); b = a; endtask
  task automatic t3(input int unsigned a, output int unsigned b); b = a; endtask
  task automatic t4(input integer  a, output integer  b); b = a; endtask
  task automatic t5(input integer signed a, output integer signed b); b = a; endtask
  task automatic t6(input integer unsigned a, output integer unsigned b); b = a; endtask
  task automatic t7(input shortint  a, output shortint  b); b = a; endtask
  task automatic t8(input shortint signed a, output shortint signed b); b = a; endtask
  task automatic t9(input shortint unsigned a, output shortint unsigned b); b = a; endtask
  task automatic t10(input longint  a, output longint  b); b = a; endtask
  task automatic t11(input longint signed a, output longint signed b); b = a; endtask
  task automatic t12(input longint unsigned a, output longint unsigned b); b = a; endtask
  task automatic t13(input byte  a, output byte  b); b = a; endtask
  task automatic t14(input byte signed a, output byte signed b); b = a; endtask
  task automatic t15(input byte unsigned a, output byte unsigned b); b = a; endtask
  task automatic t16(input bit  a, output bit  b); b = a; endtask
  task automatic t17(input bit signed a, output bit signed b); b = a; endtask
  task automatic t18(input bit unsigned a, output bit unsigned b); b = a; endtask
  task automatic t19(input logic  a, output logic  b); b = a; endtask
  task automatic t20(input logic signed a, output logic signed b); b = a; endtask
  task automatic t21(input logic unsigned a, output logic unsigned b); b = a; endtask
  task automatic t22(input reg  a, output reg  b); b = a; endtask
  task automatic t23(input reg signed a, output reg signed b); b = a; endtask
  task automatic t24(input reg unsigned a, output reg unsigned b); b = a; endtask
endmodule
