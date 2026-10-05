// § unitTdRetVarAtTypeToken245
// a module function returning a $unit string typedef, a task with a string local
typedef string us_t;
module top;
  function automatic us_t name(int k);
    return $sformatf("n%0d", k);
  endfunction
  task automatic show();
    us_t s;
    s = name(3);
    $display("%s", s);
  endtask
  initial show();
endmodule
