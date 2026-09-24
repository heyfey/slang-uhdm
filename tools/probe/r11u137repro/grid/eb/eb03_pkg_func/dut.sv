// § elabCloneFullNameUnstored137
package my_types;
  function automatic int minus(input int value1, input int value2);
    begin
      minus = value1 - value2;
    end
  endfunction
endpackage
module t(output int o);
  assign o = my_types::minus(5, 3);
endmodule
