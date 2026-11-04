// § clsMethodOwnAutomatic462
class O;
  class I;
    function automatic int f(); return 1; endfunction
  endclass
  task automatic t(); endtask
endclass
module top;
  initial begin O o; o = new; end
endmodule
