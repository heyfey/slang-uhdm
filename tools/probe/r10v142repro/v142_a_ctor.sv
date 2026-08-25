// r10v142 verifier arm A — CONSTRUCTORS, lifetimes, qualifiers, begin-blocks.
// The paren-less `function new;` is the shape the law's blockItems9 selector
// calls TF-ITEM but Surelog compiles through a DIFFERENT function
// (compileClassConstructorDeclaration).
package pv1142;
  class Kv1142;
    int f;
  endclass

  class Cv1142;
    Kv1142 v_prop;
    function new;                       // PAREN-LESS constructor
      Kv1142 ct_n;
      Kv1142 ct_i = new();
    endfunction
  endclass

  class Cv2142;
    function new();                     // paren'd constructor
      Kv1142 ctb_n;
      Kv1142 ctb_i = new();
    endfunction
  endclass

  class Cv3142;
    extern function new;
    extern function void new2();
  endclass
  function Cv3142::new;                 // OUT-OF-BODY paren-less constructor
    Kv1142 oct_n;
  endfunction
  function void Cv3142::new2();
    Kv1142 octb_n;
  endfunction

  class Cv4142;
    virtual function void vtf;
      Kv1142 v_n;
    endfunction
    virtual function void vbl();
      Kv1142 vb_n;
    endfunction
    static function void stf;
      Kv1142 s_n;
    endfunction
    static function void sbl();
      Kv1142 sb_n;
    endfunction
    protected function void ptf;
      Kv1142 p_n;
    endfunction
    function automatic void atf;
      Kv1142 a_n;
    endfunction
    function void btf;
      Kv1142 out_n;                     // tf-item
      begin
        Kv1142 blk_n;                   // block-item INSIDE a tf-item function
      end
    endfunction
    function void bbl();
      Kv1142 outb_n;
      begin
        Kv1142 blkb_n;
      end
    endfunction
  endclass

  // package free subroutines with a begin block
  function void gv142;
    Kv1142 g_out;
    begin
      Kv1142 g_blk;
    end
  endfunction
  function void gblv142();
    Kv1142 gb_out;
    begin
      Kv1142 gb_blk;
    end
  endfunction
endpackage
