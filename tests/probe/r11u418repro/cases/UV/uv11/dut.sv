// § unitVarRefMintsNet418
int dun;
module top;
  function void f;
    int dun;
    dun = 10;
    $display("%0d", dun);
  endfunction
  initial f();
endmodule
