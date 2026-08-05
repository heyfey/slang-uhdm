// t33e — t33d WITHOUT the `$unit` import: the class-property route is open,
// so `this.p_a` should read string_var (the assoc INDEX rule) unless the
// SHADOWING FORMAL wins, in which case it reads class_var 'Cel'.  Also pins
// the plain `string` property arm (uvm_component::get_depth's
// `foreach (m_name[i])`, which golden types string_var where we answer
// int_var).
package pk;
  class Cel;
    int v;
  endclass
  class C;
    int p_a[string];
    int p_b[string];
    string p_s;
    extern function void run(ref Cel p_a[$]);
  endclass
  function void C::run(ref Cel p_a[$]);
    foreach (this.p_a[i]) $display("a %0d", i);
    foreach (this.p_b[j]) $display("b %0d", j);
    foreach (this.p_s[k]) $display("s %0d", k);
    foreach (p_s[m]) $display("s2 %0d", m);
  endfunction
endpackage

module top;
  pk::C c;
  initial c = new();
endmodule
