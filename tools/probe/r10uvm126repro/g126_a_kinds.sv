// r10uvm126 grid A - ELEMENT KIND against the head's home (a CLASS TASK body's
// BLOCK-ITEM fixed-size unpacked array), one declaration per kind.  Deliberately
// NOT self-confirming: names, orders, widths and sizes all differ.
package pk_alpha126;

  typedef enum bit [2:0] { E_RED = 3'd1, E_AMBER = 3'd4 } paint126_e;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } psplit126_t;
  typedef struct { int deep; string tag; } uwrap126_t;
  typedef int cnt126_t;
  typedef string label126_t;

  class Widget126;
    int serial;
  endclass

  class Bench126;
    virtual task drive();
      string        mode126 [8];          // THE HEAD SHAPE
      real          angle126 [3];
      byte          crumb126 [5];
      chandle       hook126 [2];
      event         ping126 [7];
      shortreal     tiny126 [4];
      longint       wide126 [2];
      shortint      slim126 [6];
      integer       intg126 [3];
      time          stamp126 [2];
      bit           flag126 [9];
      bit    [7:0]  octet126 [2];
      logic  [3:0]  nib126 [5];
      logic         lone126 [4];
      reg    [1:0]  duo126 [3];
      int           plain126 [2];
      paint126_e    hue126 [4];
      psplit126_t   split126 [2];
      uwrap126_t    wrap126 [3];
      Widget126     parts126 [2];
      cnt126_t      tally126 [5];
      label126_t    caption126 [2];
      mode126[0] = "bash";
      angle126[1] = 0.5;
      crumb126[2] = 8'd3;
      hook126[0] = null;
      tiny126[3] = 1.0;
      wide126[1] = 64'd9;
      slim126[5] = 16'd2;
      intg126[2] = 7;
      stamp126[0] = 10;
      flag126[8] = 1'b1;
      octet126[1] = 8'hAA;
      nib126[4] = 4'h5;
      lone126[3] = 1'b0;
      duo126[2] = 2'b10;
      plain126[1] = 42;
      hue126[3] = E_AMBER;
      split126[1].hi = 4'h2;
      wrap126[2].deep = 11;
      parts126[1] = null;
      tally126[4] = 13;
      caption126[1] = "cap";
      ping126[6] = null;
    endtask
  endclass

endpackage
