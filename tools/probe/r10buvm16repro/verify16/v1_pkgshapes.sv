// r10vbuvm16 arm v1 — A PACKAGE AND NOTHING ELSE (BuildUVMPkg's shape).
// Every size-expression SHAPE the verifier task names, under a dynamic-array
// `new[...]`, in every subroutine home a package can hold.
package vpk1;

  int vpkvar;                 // a PACKAGE variable  (golden BINDS)
  int vpkarr[];
  typedef struct packed { int a; int b; } vst_t;

  function automatic int vhelp(int x); return x + 1; endfunction

  class vbase;
    int bprop;
    int barr[];
    function new(); bprop = 3; endfunction
  endclass

  class vcls extends vbase;
    int vprop;
    int vq[$];
    int vda[];
    int vstat;
    static int vsprop;
    vst_t vstru;
    int vfix[4];

    // ---- IN-BODY methods (classMethodNoBind already silences these) ----
    function void ib_local();
      int iloc;
      vda = new[iloc];           // v_ib_local
    endfunction

    // ---- out-of-body declarations ----
    extern function void ob_local();
    extern function void ob_formal(int ofm);
    extern function void ob_prop();
    extern function void ob_thisprop();
    extern function void ob_superprop();
    extern function void ob_pkgvar();
    extern function void ob_const();
    extern function void ob_oper();
    extern function void ob_call();
    extern function void ob_nestnew();
    extern function void ob_size();
    extern function void ob_bits();
    extern function void ob_qsize();
    extern function void ob_localqsize();
    extern function void ob_copy2();
    extern function void ob_namedblk();
    extern function void ob_unnamedblk();
    extern function void ob_foreach();
    extern function void ob_forloop();
    extern function void ob_shadow();
    extern function void ob_struct();
    extern function void ob_arrsel();
    extern task ob_fork();
    extern function void ob_ternary();
    extern task ob_task(int tfm);
    extern static function void ob_static();
    extern function void ob_newclass(int nca);
  endclass

  function void vcls::ob_local();       int oloc;  vda = new[oloc];              endfunction
  function void vcls::ob_formal(int ofm);          vda = new[ofm];               endfunction
  function void vcls::ob_prop();                   vda = new[vprop];             endfunction
  function void vcls::ob_thisprop();               vda = new[this.vprop];        endfunction
  function void vcls::ob_superprop();              vda = new[super.bprop];       endfunction
  function void vcls::ob_pkgvar();                 vda = new[vpkvar];            endfunction
  function void vcls::ob_const();                  vda = new[7];                 endfunction
  function void vcls::ob_oper();        int ooa;   vda = new[ooa + vpkvar];      endfunction
  function void vcls::ob_call();        int oca;   vda = new[vhelp(oca)];        endfunction
  function void vcls::ob_nestnew();     int onn;   vda = new[onn]; barr = new[onn](vda); endfunction
  function void vcls::ob_size();        int osz[]; vda = new[$size(osz)];        endfunction
  function void vcls::ob_bits();        int obt;   vda = new[$bits(obt)];        endfunction
  function void vcls::ob_qsize();                  vda = new[vq.size()];         endfunction
  function void vcls::ob_localqsize();  int olq[$];vda = new[olq.size()];        endfunction
  function void vcls::ob_copy2();       int ocn; int ocs[]; vda = new[ocn](ocs); endfunction
  function void vcls::ob_namedblk();    begin : nb1 int nloc; vda = new[nloc]; end endfunction
  function void vcls::ob_unnamedblk();  begin      int uloc; vda = new[uloc]; end endfunction
  function void vcls::ob_foreach();     foreach (vfix[fei]) vda = new[fei];      endfunction
  function void vcls::ob_forloop();     for (int fli = 0; fli < 2; fli++) vda = new[fli]; endfunction
  function void vcls::ob_shadow();      int vprop; vda = new[vprop];             endfunction
  function void vcls::ob_struct();                 vda = new[vstru.a];           endfunction
  function void vcls::ob_arrsel();      int asi;   vda = new[vfix[asi]];         endfunction
  task automatic vcls::ob_fork();      int fkl;   fork vda = new[fkl]; join     endtask
  function void vcls::ob_ternary();     int tca; int tcb; vda = new[tca ? tcb : vpkvar]; endfunction
  task vcls::ob_task(int tfm);          int tloc;  vda = new[tfm + tloc];        endtask
  function void vcls::ob_static();      int stl;   vsprop = stl;                 endfunction
  function void vcls::ob_newclass(int nca);
    vbase nb; int ncl;
    nb = new();                    // v_newclass_zero
    vda = new[nca + ncl];          // v_newclass_size
  endfunction

  // ---- PACKAGE-level subroutines (no class at all) ----
  function automatic void vpfn(int pfm);
    int pfl;
    vpkarr = new[pfl];             // v_pkgfn_local
    vpkarr = new[pfm];             // v_pkgfn_formal
    vpkarr = new[vpkvar];          // v_pkgfn_pkgvar  (golden BINDS)
  endfunction

  task automatic vptk(int tkm);
    int tkl;
    vpkarr = new[tkl + tkm];
  endtask

endpackage
