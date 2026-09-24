// r10uvm145 arm B — KIND x INITIALISER-SHAPE, under BOTH productions.
// kinds: class handle / bit / int / string / enum / struct / queue / real
// shapes: literal / call / new / null / expression / another local
// MEASUREMENT ONLY.
package pb145;

  typedef enum { EB_LOW, EB_MID, EB_TOP } eb145_e;
  typedef struct packed { bit [3:0] hi; bit [3:0] lo; } sb145_t;

  class Widget145;
    int wv;
    static function Widget145 mint145();
      Widget145 w = new();
      w.wv = 6;
      return w;
    endfunction
    function int val145();
      return wv;
    endfunction
  endclass

  function int helper145(int a);
    return a + 1;
  endfunction

  // ================= TF-ITEM (paren-less) =================
  function void kindsNoParen145;
    Widget145      cHand = Widget145::mint145();   // class handle <- CALL
    Widget145      cNew  = new();                  // class handle <- NEW
    Widget145      cNul  = null;                   // class handle <- NULL
    bit            bLit  = 1'b1;                   // bit          <- literal
    int            iCall = helper145(4);           // int          <- call
    string         sLit  = "vee";                  // string       <- literal
    eb145_e        eLit  = EB_MID;                 // enum         <- literal
    sb145_t        tLit  = '{hi:4'h3, lo:4'hC};    // struct       <- literal
    real           rLit  = 2.5;                    // real         <- literal
    int            qEx   = 3 + 4 * 5;              // int          <- expression
    int            qLoc  = iCall;                  // int          <- another local
    $display(cHand, cNew, cNul, bLit, iCall, sLit, eLit, tLit, rLit, qEx, qLoc);
    $display(bLit);
  endfunction

  function void queueNoParen145;
    int    qArr[$] = {1, 2, 3};
    int    dArr[]  = new[2];
    string aArr[string];
    int    fArr[3] = '{7, 8, 9};
    qArr.push_back(4);
    $display(qArr.size(), dArr.size(), aArr.size(), fArr[0]);
  endfunction

  // ================= BLOCK-ITEM (paren) =================
  function void kindsParen145();
    Widget145      cHand = Widget145::mint145();
    Widget145      cNew  = new();
    Widget145      cNul  = null;
    bit            bLit  = 1'b1;
    int            iCall = helper145(4);
    string         sLit  = "vee";
    eb145_e        eLit  = EB_MID;
    sb145_t        tLit  = '{hi:4'h3, lo:4'hC};
    real           rLit  = 2.5;
    int            qEx   = 3 + 4 * 5;
    int            qLoc  = iCall;
    $display(cHand, cNew, cNul, bLit, iCall, sLit, eLit, tLit, rLit, qEx, qLoc);
    $display(bLit);
  endfunction

  function void queueParen145();
    int    qArr[$] = {1, 2, 3};
    int    dArr[]  = new[2];
    string aArr[string];
    int    fArr[3] = '{7, 8, 9};
    qArr.push_back(4);
    $display(qArr.size(), dArr.size(), aArr.size(), fArr[0]);
  endfunction

  // ================= the same kinds inside a TASK, both ways =============
  task kindsTaskIo145;
    input int seed;
    Widget145 tHand = Widget145::mint145();
    string    tStr  = "kay";
    int       tInt  = seed * 3;
    $display(tHand, tStr, tInt);
    $display(seed);
  endtask

  task kindsTaskNoIo145;
    Widget145 tHand = Widget145::mint145();
    string    tStr  = "kay";
    int       tInt  = 9;
    $display(tHand, tStr, tInt);
    $display(tInt);
  endtask

endpackage
