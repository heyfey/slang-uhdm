// r10v126 arm B - DECLARATION FORMS the implementer's grids never wrote:
// `var`, explicit lifetimes, const, multi-declarator, implicit-typed, and the
// same string array reached through a typedef of an ARRAY.  Different names,
// sizes and orders from every grid126 cell.
package pk_frm126v;
  typedef string      sname126v;
  typedef string      srow126v [3];
  typedef byte        bname126v;
  class Forms126v;
    virtual task go();
      var string        v_str126v  [2];   // `var` prefix
      var byte          v_byt126v  [3];
      automatic string  a_str126v  [4];   // explicit lifetime
      automatic real    a_rea126v  [5];
      static   string   s_str126v  [6];
      const    string   c_str126v  [2] = '{"p","q"};
      string            m1_126v [2], m2_126v [7];   // TWO declarators, ONE type
      real              n1_126v [3], n2_126v [4];
      sname126v         td_str126v [5];   // typedef of string  (NAMED - excluded)
      srow126v          ta_str126v;       // typedef of the ARRAY itself
      bname126v         td_byt126v [6];
      v_str126v[0]="v"; v_byt126v[1]=8'd1;
      a_str126v[2]="a"; a_rea126v[3]=1.5;
      s_str126v[4]="s";
      m1_126v[1]="m"; m2_126v[6]="n"; n1_126v[2]=2.5; n2_126v[3]=3.5;
      td_str126v[4]="t"; ta_str126v[2]="u"; td_byt126v[5]=8'd2;
      $display(c_str126v[0]);
    endtask
  endclass
endpackage
