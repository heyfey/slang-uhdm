// r10v153 arm F — EVERY CONSTRUCTOR-LOCAL LISTING FACE, then a class property
// of the SAME NAME read from an out-of-body method.  § 153 binds BY NAME to
// whatever the package listing holds, so this arm asks two questions at once:
// does our listing hold the same NAMES in the same ORDER as golden's, and does
// the property bind the same entry?  LHS is always golden.
package pvf153;

  typedef class Kvf153;
  class Kvf153; int fk; endclass
  typedef Kvf153 KAlias;

  // ---- donor 1: NO port list, the EATEN first element (§ 152) --------------
  class D1vf153;
    extern function new;
  endclass
  function D1vf153::new;
    int f_eaten;                 // the eaten first element
    int f_body;                  // a plain body-level local
    begin
      int f_nest;                // a nested-begin local
      begin
        int f_nest2;             // DOUBLY nested
        f_nest2 = 1;
      end
      f_nest = 2;
    end
    fork
      begin int f_fork; f_fork = 3; end
    join_none
    for (int f_forv = 0; f_forv < 2; f_forv++) begin
      int f_forb;                // a for-BODY local
      f_forb = f_forv;
    end
    begin : f_named
      int f_inname;              // a NAMED block local
      f_inname = 4;
    end
    case (f_body)
      1: begin int f_case; f_case = 5; end
      default: begin int f_dflt; f_dflt = 6; end
    endcase
    if (f_body == 0) begin
      int f_ifarm;               // an if-ARM local
      f_ifarm = 7;
    end
    f_eaten = 8;
    f_body  = 9;
  endfunction

  // ---- donor 2: WITH a port list, kinds, declarator counts, init reads -----
  class D2vf153;
    extern function new(int q);
  endclass
  function D2vf153::new(int q);
    Kvf153 f_hand;               // a class handle
    KAlias f_alias;              // a TYPEDEF'd handle
    string f_str;                // a string
    int    f_q[$];               // a queue
    int    f_arr[4];             // a fixed array
    int    f_d1, f_d2, f_d3;     // THREE declarators on one line
    int    f_init = q;           // an initializer
    int    f_init2 = f_init;     // an initializer READING another local
    f_hand = null; f_alias = null; f_str = "s";
    f_q.push_back(q); f_arr[0] = q;
    f_d1 = q; f_d2 = q; f_d3 = q;
  endfunction

  // ---- donor 3: a SECOND constructor reusing donor 1's names --------------
  class D3vf153;
    extern function new;
  endclass
  function D3vf153::new;
    int f_body;                  // the SAME name in a second constructor
    int f_dup3;
    f_body = 10;
    f_dup3 = 11;
  endfunction

  // ---- donor 4: a derived class whose local comes AFTER super.new() -------
  class D4vf153 extends D1vf153;
    extern function new;
  endclass
  function D4vf153::new;
    super.new();
    begin
      int f_after;               // declared after super.new()
      f_after = 12;
    end
  endfunction

  // ---- a package FREE function beside the constructors --------------------
  function int ffree153(int a);
    int f_free;                  // a package FUNCTION local: NOT collected
    f_free = a;
    ffree153 = f_free;
  endfunction

  // ---- the READER: a class property per face ------------------------------
  class Rvf153;
    int    f_eaten;
    int    f_body;
    int    f_nest;
    int    f_nest2;
    int    f_fork;
    int    f_forv;
    int    f_forb;
    int    f_inname;
    int    f_case;
    int    f_dflt;
    int    f_ifarm;
    Kvf153 f_hand;
    KAlias f_alias;
    string f_str;
    int    f_q[$];
    int    f_arr[4];
    int    f_d1;
    int    f_d2;
    int    f_d3;
    int    f_init;
    int    f_init2;
    int    f_dup3;
    int    f_after;
    int    f_free;
    extern function void rd153(int p);
  endclass

  function void Rvf153::rd153(int p);
    f_eaten  = p;
    f_body   = p;
    f_nest   = p;
    f_nest2  = p;
    f_fork   = p;
    f_forv   = p;
    f_forb   = p;
    f_inname = p;
    f_case   = p;
    f_dflt   = p;
    f_ifarm  = p;
    f_hand   = null;
    f_alias  = null;
    f_str    = "z";
    f_arr[0] = p;
    f_d1     = p;
    f_d2     = p;
    f_d3     = p;
    f_init   = p;
    f_init2  = p;
    f_dup3   = p;
    f_after  = p;
    f_free   = p;
  endfunction

endpackage
