// § clsMethodOwnAutomatic462
program pr;
  class C;
    task automatic t(); endtask
  endclass
  initial begin C c; c = new; c.t(); end
endprogram
module top;
  pr u();
endmodule
