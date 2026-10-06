// § retTopRangeOwnPkg269 (control: no package imports the home)
package up;
  parameter W = 4;
  parameter LS = W*8-1;
  function logic [LS:0] s2b(string str);
    $swrite(s2b, "%0s", str);
  endfunction
endpackage
module top; endmodule
