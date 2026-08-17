// vsd12 cell v3 — `$unit` SCOPE, the arm r10sd10's `g9` built and this law
// inherits WITHOUT re-measuring at the element site.  A `$unit`-level class is
// registered `work@<name>`, which no written scope spells, so the SCOPED arm's
// REACH term fails for a `$unit` owner AND for a `$unit` class's OWN typedef
// written with its own scope, while the BARE arm resolves lexically.
//
// The scalar twin is declared beside every element row: the law says they must
// agree, so a row where they DISAGREE refutes the law as stated.
class uown3;
  typedef int                      u_t;
  typedef struct packed { int f; } us_t;
endclass

class uuser3;
  typedef uown3::u_t own3_t;

  function void f3();
    uown3::u_t   s_q[$];        // SCOPED, $unit owner -> reach fails
    uown3::u_t   s_s;
    uown3::us_t  t_fx[2];       // the same, fixed-size, struct target
    uown3::us_t  t_s;
    uuser3::own3_t sf_q[$];     // the $unit class's OWN typedef, SELF-qualified
    uuser3::own3_t sf_s;
    own3_t       b_q[$];        // BARE own typedef -> lexical, resolves
    own3_t       b_s;
    s_q = {};
    b_q = {};
  endfunction
endclass

module topv3;
  initial begin
    uuser3 u = new();
    u.f3();
  end
endmodule
