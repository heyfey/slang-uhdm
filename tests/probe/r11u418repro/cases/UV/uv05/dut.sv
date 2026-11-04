// § unitVarRefMintsNet418
string label = "X";
module top;
  function automatic void show();
    $display("%s", label);
  endfunction
  initial show();
endmodule
