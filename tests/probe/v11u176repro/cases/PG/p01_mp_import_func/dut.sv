// § progLowConnDefModport176
interface ConnectTB;
  logic drive;
  logic observe;
  function automatic void set(input logic v);
    drive = v;
  endfunction
  modport tb (output drive, input observe, import set);
endinterface
program TESTBENCH (ConnectTB.tb intf);
  initial intf.set(1'b1);
endprogram
module TOP();
  ConnectTB conntb();
  TESTBENCH tb(.intf(conntb));
endmodule
