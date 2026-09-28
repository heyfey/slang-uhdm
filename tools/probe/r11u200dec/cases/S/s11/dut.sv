module s11;
  function int f1;
    input int  a;
    f1 = a;
  endfunction
  task t1;
    output int  b;
    b = 0;
  endtask
  function int f2;
    input int signed a;
    f2 = a;
  endfunction
  task t2;
    output int signed b;
    b = 0;
  endtask
  function int f3;
    input int unsigned a;
    f3 = a;
  endfunction
  task t3;
    output int unsigned b;
    b = 0;
  endtask
  function int f4;
    input integer  a;
    f4 = a;
  endfunction
  task t4;
    output integer  b;
    b = 0;
  endtask
  function int f5;
    input integer signed a;
    f5 = a;
  endfunction
  task t5;
    output integer signed b;
    b = 0;
  endtask
  function int f6;
    input integer unsigned a;
    f6 = a;
  endfunction
  task t6;
    output integer unsigned b;
    b = 0;
  endtask
  function int f7;
    input shortint  a;
    f7 = a;
  endfunction
  task t7;
    output shortint  b;
    b = 0;
  endtask
  function int f8;
    input shortint signed a;
    f8 = a;
  endfunction
  task t8;
    output shortint signed b;
    b = 0;
  endtask
  function int f9;
    input shortint unsigned a;
    f9 = a;
  endfunction
  task t9;
    output shortint unsigned b;
    b = 0;
  endtask
  function int f10;
    input longint  a;
    f10 = a;
  endfunction
  task t10;
    output longint  b;
    b = 0;
  endtask
  function int f11;
    input longint signed a;
    f11 = a;
  endfunction
  task t11;
    output longint signed b;
    b = 0;
  endtask
  function int f12;
    input longint unsigned a;
    f12 = a;
  endfunction
  task t12;
    output longint unsigned b;
    b = 0;
  endtask
  function int f13;
    input byte  a;
    f13 = a;
  endfunction
  task t13;
    output byte  b;
    b = 0;
  endtask
  function int f14;
    input byte signed a;
    f14 = a;
  endfunction
  task t14;
    output byte signed b;
    b = 0;
  endtask
  function int f15;
    input byte unsigned a;
    f15 = a;
  endfunction
  task t15;
    output byte unsigned b;
    b = 0;
  endtask
  function int f16;
    input bit  a;
    f16 = a;
  endfunction
  task t16;
    output bit  b;
    b = 0;
  endtask
  function int f17;
    input bit signed a;
    f17 = a;
  endfunction
  task t17;
    output bit signed b;
    b = 0;
  endtask
  function int f18;
    input bit unsigned a;
    f18 = a;
  endfunction
  task t18;
    output bit unsigned b;
    b = 0;
  endtask
  function int f19;
    input logic  a;
    f19 = a;
  endfunction
  task t19;
    output logic  b;
    b = 0;
  endtask
  function int f20;
    input logic signed a;
    f20 = a;
  endfunction
  task t20;
    output logic signed b;
    b = 0;
  endtask
  function int f21;
    input logic unsigned a;
    f21 = a;
  endfunction
  task t21;
    output logic unsigned b;
    b = 0;
  endtask
  function int f22;
    input reg  a;
    f22 = a;
  endfunction
  task t22;
    output reg  b;
    b = 0;
  endtask
  function int f23;
    input reg signed a;
    f23 = a;
  endfunction
  task t23;
    output reg signed b;
    b = 0;
  endtask
  function int f24;
    input reg unsigned a;
    f24 = a;
  endfunction
  task t24;
    output reg unsigned b;
    b = 0;
  endtask
endmodule
