// § unitTdRetVarAtTypeToken245
// a CRLF file: a $unit int and string typedef on a function return and a task local
typedef int ui_t;
typedef string us_t;
module top(input int i, output int o);
  function automatic ui_t twice(ui_t a);
    return a * 2;
  endfunction
  task automatic t();
    us_t s;
    s = "a";
  endtask
  assign o = twice(i);
endmodule
