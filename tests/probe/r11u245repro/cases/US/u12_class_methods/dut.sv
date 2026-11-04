// § unitTdLawS245
// $unit typedefs in a $unit class: properties, method formals, locals and returns
typedef int ui_t;
typedef string us_t;
typedef logic [7:0] ub_t;
class c;
  ui_t m_i;
  us_t m_s;
  ub_t m_b;
  function ui_t get(us_t s, ub_t b);
    ui_t l;
    l = s.len() + b;
    return l;
  endfunction
  task put(input ub_t b, output us_t s);
    s = "x";
  endtask
endclass
module top;
  c o;
  initial o = new;
endmodule
