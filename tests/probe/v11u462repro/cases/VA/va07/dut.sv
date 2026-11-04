// § clsMethodOwnAutomatic462
module top;
  class C;
    task automatic t(); endtask
    function automatic int f(); return 1; endfunction
  endclass
  C c;
  function automatic int g(); return 2; endfunction
endmodule
