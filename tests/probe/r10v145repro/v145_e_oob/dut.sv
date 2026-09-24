// r10v145 arm E -- OUT-OF-BODY methods, and a TF-ITEM-production method beside
// a BLOCK-ITEM-production method in ONE class; virtual / static / pure-virtual
// overriders; a void function; kinds beyond int.  MEASUREMENT ONLY.
package pe145v;

  class Ke145v;
    int f;
    function new(); f = 1; endfunction
    static function int sget(); return 7; endfunction
  endclass

  typedef enum int { EA145V = 1, EB145V = 2 } e145v_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } s145v_t;

  // ---- out-of-body definitions, both productions ----
  class Oob145v;
    int f;
    extern function void om1145v;             // paren-less prototype => TF-ITEM
    extern function void om2145v();           // paren prototype      => BLOCK-ITEM
    extern task ot1145v(input int p);
    extern virtual function int ov1145v;
    // TF-ITEM and BLOCK-ITEM in-body methods side by side
    function void im1145v;
      int x1 = 1;
      int x2 = 2;
      $display(x1, x2);
      $display(x1);
    endfunction
    function void im2145v();
      int x1 = 1;
      int x2 = 2;
      $display(x1, x2);
      $display(x1);
    endfunction
    static function void im3145v;
      int x3 = 3;
      int x4 = 4;
      $display(x3, x4);
      $display(x3);
    endfunction
  endclass

  function void Oob145v::om1145v;
    int y1 = 1;
    int y2 = 2;
    $display(y1, y2);
    $display(y1);
  endfunction

  function void Oob145v::om2145v();
    int y1 = 1;
    int y2 = 2;
    $display(y1, y2);
    $display(y1);
  endfunction

  task Oob145v::ot1145v(input int p);
    int y3 = 3;
    int y4 = 4;
    $display(y3, y4, p);
    $display(y3);
  endtask

  function int Oob145v::ov1145v;
    int y5 = 5;
    int y6 = 6;
    $display(y5);
    return y5 + y6;
  endfunction

  // ---- KINDS beyond int, both productions ----
  function void kinds_tf145v;
    bit         k1 = 1'b1;
    string      k2 = "abc";
    real        k3 = 1.5;
    e145v_t     k4 = EB145V;
    s145v_t     k5 = '{a:4'h1, b:4'h2};
    int         k6[3] = '{1,2,3};
    int         k7[$] = {1,2};
    int         k8[]  = new[2];
    int         k9[string];
    Ke145v      k10 = null;
    int         k11 = Ke145v::sget();
    $display(k1, k2, k3, k4, k5, k6[0], k7[0], k8[0], k9.size(), k10 == null, k11);
    $display(k1);
  endfunction

  function void kinds_bi145v();
    bit         k1 = 1'b1;
    string      k2 = "abc";
    real        k3 = 1.5;
    e145v_t     k4 = EB145V;
    s145v_t     k5 = '{a:4'h1, b:4'h2};
    int         k6[3] = '{1,2,3};
    int         k7[$] = {1,2};
    int         k8[]  = new[2];
    int         k9[string];
    Ke145v      k10 = null;
    int         k11 = Ke145v::sget();
    $display(k1, k2, k3, k4, k5, k6[0], k7[0], k8[0], k9.size(), k10 == null, k11);
    $display(k1);
  endfunction

endpackage
