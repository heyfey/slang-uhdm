// § typenameKwIsString405
module top();
  function automatic string f();
    return $typename(byte);
  endfunction
  initial $display("%s %s", f(), $typename(shortreal));
endmodule
