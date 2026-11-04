// § unitTdRetVarAtTypeToken245
// a $unit string typedef used by a module task formal, a function local and return
typedef string ustr_t;
module top;
  function automatic ustr_t f(input ustr_t a);
    ustr_t l;
    l = a;
    return l;
  endfunction
  task automatic t(ustr_t x); $display(x); endtask
  initial t(f("x"));
endmodule
