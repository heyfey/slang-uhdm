// § unitPredefAliasOfAlias245
// a $unit string typedef and its alias, used by module variables and a function formal
typedef string ustr_t;
typedef ustr_t ual_t;
module top;
  ustr_t u;
  ual_t a;
  function automatic int f(ustr_t s); return s.len(); endfunction
endmodule
