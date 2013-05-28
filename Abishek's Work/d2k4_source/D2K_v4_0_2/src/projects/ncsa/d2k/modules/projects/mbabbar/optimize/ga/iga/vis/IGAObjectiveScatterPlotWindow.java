package ncsa.d2k.modules.projects.mbabbar.optimize.ga.iga.vis;

import java.util.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.JScrollPane;
import javax.swing.border.Border;
import javax.swing.ImageIcon;
import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.JToolBar;
import javax.swing.JButton;
import javax.swing.border.*;
import javax.swing.SwingUtilities;
import javax.swing.table.*;
import javax.swing.plaf.*;
import javax.swing.plaf.basic.*;


import ncsa.d2k.core.modules.*;
import ncsa.d2k.userviews.swing.*;
import ncsa.d2k.modules.core.optimize.util.*;
import ncsa.d2k.modules.core.optimize.ga.emo.*;
import ncsa.d2k.modules.core.optimize.ga.emo.gui.*;
import ncsa.d2k.modules.core.datatype.table.*;
import ncsa.d2k.modules.core.datatype.table.basic.*;
import ncsa.d2k.modules.core.io.file.output.*;
import ncsa.d2k.modules.core.vis.widgets.*;
import ncsa.d2k.modules.projects.mbabbar.optimize.ga.iga.*;
import ncsa.d2k.gui.*;
import ncsa.gui.*;

/**
 * This module displays the selected individuals for comparative rating.
 *
 * @author Meghna Babbar
 */
public class IGAObjectiveScatterPlotWindow extends UIModule {

////////////////////////////////////////////////////////////////////////////////
// Module methods                                                             //
////////////////////////////////////////////////////////////////////////////////

   public UserView createUserView() {
      return new IGAScatterPlotView();
   }

   /**
    * Not used by this module.
    */
   public String[] getFieldNameMapping() {
      return null;
   }

   public String getInputInfo(int i) {
      if (i == 0)
         return "The <i>IGA NSGA Population</i>.";
      return "No such input";
   }

   public String getInputName(int i) {
      if (i == 0)
         return "Multiobjective NSGA Population";
      return "No such input";
   }

   public String[] getInputTypes() {
      return new String[] {
         "ncsa.d2k.modules.projects.mbabbar.optimize.ga.iga.IGANsgaPopulation"
      };
   }

   public String getModuleInfo() {
      StringBuffer sb = new StringBuffer("<p>Overview: ");
      sb.append("This module displays the Objective Tradeoffs scatterplots. Individuals selected through this interactive display are absorbed into the pool of individuals that are later displayed for ranking");
      return sb.toString();
   }

   public String getModuleName() {
      return "IGA: Objectives Tradeoff Section";
   }

   public String getOutputInfo(int i) {
      if (i == 0)
         return "The <i>IGA NSGA Population</i>.";
      else if (i == 1)
         return "The <i>Table</i> that contains individuals selected from tradeoff plots";
      return "No such output";
   }

   public String getOutputName(int i) {
      if (i == 0)
         return "Multiobjective IGA NSGA Population";
      else if (i == 1)
         return "Table";
      return "No such output";
   }

   public String[] getOutputTypes() {
      return new String[] { "ncsa.d2k.modules.projects.mbabbar.optimize.ga.iga.IGANsgaPopulation",
         "ncsa.d2k.modules.core.datatype.table.Table"
      };
    // return null;
   }
////////////////////////////////////////////////////////////////////////////////
// user view                                                                  //
////////////////////////////////////////////////////////////////////////////////

   /**
    * This class uses a <code>NsgaPopulation</code> to display the
    * <code>Objective Tradeoff Scatter Plots</code>.
    */
   public class IGAScatterPlotView extends JUserPane implements ActionListener {

      /** a reference to our parent module */
      protected IGAObjectiveScatterPlotWindow parent;
      /** Back button */
      protected JButton back;
      /** Next button */
      protected JButton next;
      /** Quit button */
      protected JButton quit;
      /** JButton Panel for back, quit and next buttons */
      protected JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
      /** panels to display ScatterPlots */
      protected JScrollPane scatterPlotPanel; // = new JPanel();

      /** the maximum number of generations of the current population */
      private int maxGen = 0;

      /** the current generation of the current population */
      private int currentGen = 0;

      /** the current population */
      private IGANsgaPopulation currentPop;
      private PopInfo currentPopInfo;
      private MutableTableImpl currentPopTable;

      // which objectives out of all the objectives are qualitative.
      // This array has size 'number of objectives', and if objective #1 is qualitative
      // then qualObjs[1] = true.
      boolean [] qualObjs;

      abstract class Runner
        implements Runnable {};
      /**
         Initialize the view.  Insert all components into the view.
         @param mod The IGAObjectiveScatterPlotWindow module that owns us
         */
      public void initView(ViewModule mod) {
         parent = (IGAObjectiveScatterPlotWindow)mod;

            // Main Button Panel
            float h,s,b;
            h = 0.219F;
            s = 0.141F;
            b = 0.823F;
            buttonPanel.setBackground(Color.getHSBColor(h,s,b));
            buttonPanel.setBorder(BorderFactory.createLineBorder(Color.white,2));
            back = new JButton("Back");
            back.addActionListener(this);

            quit = new JButton("Quit");
            quit.addActionListener(new AbstractAction() {
              public void actionPerformed(ActionEvent e) {
                viewCancel();
              }
            });
            buttonPanel.add(quit);


            next = new JButton("Next");
            next.addActionListener(new AbstractAction() {
              public void actionPerformed(ActionEvent e) {
                boolean [] selectedIndivs = new boolean [currentPop.size()];
                // get selection flags from the scatter plots
                if (currentPop != null) {
                    for (int i = 0; i < currentPop.size() ; i++){
                        System.out.println("**************************");
                        System.out.println("selected["+i+"] "+currentPopInfo.tableModel.plots[0][0].selected[i]);
                        System.out.println("selected["+i+"] "+currentPopInfo.tableModel.plots[1][0].selected[i]);
                        System.out.println("selected["+i+"] "+currentPopInfo.tableModel.plots[0][1].selected[i]);
                        System.out.println("selected["+i+"] "+currentPopInfo.tableModel.plots[1][1].selected[i]);
                        System.out.println("**************************");

                        selectedIndivs[i] = false;
                        if((currentPopInfo.tableModel.plots[0][0].selected[i] == true) ||
                         (currentPopInfo.tableModel.plots[0][1].selected[i] == true) ||
                         (currentPopInfo.tableModel.plots[1][0].selected[i] == true) ||
                         (currentPopInfo.tableModel.plots[1][1].selected[i] == true) ){
                            selectedIndivs[i] = true;
                        }
                    }

                    // for testing
                    //for (int i = 0; i < 8 ; i++){
                      //  selectedIndivs[i+currentGen] = true;
                    //}
                    ////////////

                }
                // update selection flags to the population table
                currentPopTable.addColumn(new BooleanColumn(currentPop.size()));
                currentPopTable.setColumnLabel("Selected Individuals", currentPopTable.getNumColumns() - 1);
                for (int i =0; i < currentPopTable.getNumRows(); i++){
                    currentPopTable.setBoolean(selectedIndivs[i] , i , currentPopTable.getNumColumns() - 1);
                }

                pushOutput(currentPop, 0);
                pushOutput(currentPopTable, 1);

               // viewCancel();
                viewDone("Done");
              }
            });
            buttonPanel.add(next);

           // Dimension dim = getToolkit().getScreenSize();
            buttonPanel.setMinimumSize(new Dimension(800, 50));
            buttonPanel.createToolTip();

            add(buttonPanel, BorderLayout.SOUTH);

            // repaint();
     }

      // MenuBar
      public Object getMenu() {
         return null;
      }

      /**
         Called whenever inputs arrive to the module.
         @param input the Object that is the input
         @param idx the index of the input
         */
      public void setInput(Object input, int idx) {

            float h,s,b;
            // Tradeoff ScatterPlots Panel
            h = 0.168F;
            s = 0.208F;
            b = 0.979F;

            removeAll();
            currentPop = (IGANsgaPopulation) input;
            currentPopInfo = new CurrentPopInfo();
            currentGen = currentPop.getCurrentGeneration();
            maxGen = currentPop.getMaxGenerations();

           // System.out.println("CURRENT GEN : " +  currentGen);
           // System.out.println("MAX GEN : " +  maxGen);

            int numObjs = currentPop.getNumObjectives();
            IGANsgaSolution[] nis = (IGANsgaSolution[]) (currentPop.getMembers());
            int numSolutions = nis.length;

            // Obtaining flags for which objectives are qualitative and which are quantitative
            qualObjs = (boolean[]) (currentPop.getIgaQualObj());

            // get the names of the objectives
            int numQuantObjs = 0;
            for (int i = 0; i < numObjs; i++) {
              if (qualObjs[i] == false){
                numQuantObjs++;
              }
            }
            String[] names = new String[numQuantObjs];

            // create the table
            // final MutableTable currentPopTable = (MutableTable) DefaultTableFactory.
            ////BASIC3 currentPopTable = (MutableTable) DefaultTableFactory.getInstance().createTable();
            currentPopTable =  new MutableTableImpl(0);

            int qnOb = 0;
            for (int i = 0; i < numObjs; i++) {
              // put only quantitative objectives in the table
              if (qualObjs[i] == false){
                  names[qnOb] = currentPop.getObjectiveConstraints()[i].getName();
                  qnOb++;
                  currentPopTable.addColumn(new FloatColumn(numSolutions));
                  currentPopTable.setColumnLabel(currentPop.getObjectiveConstraints()[
                                         i].getName(),
                                         currentPopTable.getNumColumns() - 1);
              }
            }

            // fill the table
            // for each solution
            for (int i = 0; i < numSolutions; i++) {
                int j = 0;
                // copy each objective into the table
                for (int ob = 0; ob < numObjs; ob++) {
                  // put only quantitative objectives
                  if (qualObjs[ob] == false){
                    currentPopTable.setFloat( (float) nis[i].getObjective(ob), i, j);
                    j++;
                  }
                }
            }

            if (currentPop != null) {
                currentPopInfo.scatterPlot.setObjectiveNames(names);
                currentPopInfo.setPopulation(currentPop, currentPopTable);
            }

            //currentPopInfo.setMinimumSize(new Dimension(800, 620));
           JPanel pnl = new JPanel();
           pnl.setBorder(BorderFactory.createLineBorder(Color.white,2));
           pnl.add(currentPopInfo);
           pnl.setBackground(Color.getHSBColor(h,s,b));
           scatterPlotPanel = new JScrollPane(pnl);
           scatterPlotPanel.setMinimumSize(new Dimension(1000, 700));
           scatterPlotPanel.setBackground(Color.getHSBColor(h,s,b));

           // add buttonPanel and scatterPlotPanel to frame.
           add(buttonPanel, BorderLayout.SOUTH);
           add(scatterPlotPanel, BorderLayout.CENTER);
           revalidate();
           repaint();
      }

      /**
         Perform any clean up to the table and call the finish() method.
         */
      protected void finishUp() {
       //  pushOutput(table, 0);
         viewDone("Done");
      }

      /**
         This is the ActionListener for the ok and cancel buttons.  The
         finishUp() method is called if ok is pressed.  The viewCancel()
         method of the VerticalTableViewer module is called if cancel is
         pressed.
         @param e the ActionEvent
         */
      public void actionPerformed(ActionEvent e) {
         Object src = e.getSource();
      }

/////////////////////////////////////////
// Inner classes of IGAScatterPlotView //
/////////////////////////////////////////
    private class PopInfo
        extends JPanel {
      JPanel labels;
      JLabel popSize;
      JLabel numSolutions;

      String POP_SIZE = "Population Size: ";
      String NUM_SOL = "Number of Nondominated Solutions: ";
      String CUMUL = "Cumulative ";

      boolean isCumulative = false;

      ObjectiveModel tableModel;
      ObjectiveMatrix scatterPlot;

      int run;

      PopInfo() {

        popSize = new JLabel(POP_SIZE);
        numSolutions = new JLabel(NUM_SOL);

        labels = new JPanel();
        labels.setLayout(new GridLayout(2, 1));
        labels.add(popSize);
        labels.add(numSolutions);

        scatterPlot = new ObjectiveMatrix();
        tableModel = (ObjectiveModel) scatterPlot.jTable.getModel();

        this.setLayout(new BorderLayout());
       // labels.setBorder(new EmptyBorder(0, 15, 0, 0));
        add(labels, BorderLayout.NORTH);
        add(scatterPlot, BorderLayout.CENTER);
      }

      void setPopulation(IGANsgaPopulation p, MutableTable table) {

        if (p != null) {
          popSize.setText(POP_SIZE + p.getMembers().length);

          IGANsgaSolution[] nis = (IGANsgaSolution[]) p.getMembers();
          int numRankZero = 0;
          for (int i = 0; i < nis.length; i++) {
            if (nis[i].getRank() == 0) {
              numRankZero++;
            }
          }
          numSolutions.setText(NUM_SOL + numRankZero);
        }
        else {
          popSize.setText(POP_SIZE);
          numSolutions.setText(NUM_SOL);
        }

        if (table != null) {
          // always set tableModel through the mutableTable, which has the filtered quantitative
          // objectives.
          tableModel.setPopulationTable(table);
        }
        else { // if(p != null){
           System.exit(0);
          // tableModel.setPopulation(p);
        }
      }
    }
    private class CurrentPopInfo
        extends PopInfo {

      CurrentPopInfo() {
        //runNumber = new JLabel(RUN);
        popSize = new JLabel(POP_SIZE);
        numSolutions = new JLabel(NUM_SOL);
        float h,s,b;
        h = 0.219F;
        s = 0.141F;
        b = 0.823F;
        labels = new JPanel();
        labels.setLayout(new GridLayout(2, 1));
        labels.setBackground(Color.getHSBColor(h,s,b));
        labels.setBorder(BorderFactory.createLineBorder(Color.white,2));
       // labels.add(runNumber);
        labels.add(popSize);
        labels.add(numSolutions);

        scatterPlot = new ObjectiveMatrix();
        scatterPlot.setBorder(BorderFactory.createLineBorder(Color.white,2));
        tableModel = (ObjectiveModel) scatterPlot.jTable.getModel();

        this.setLayout(new BorderLayout());
       // labels.setBorder(new EmptyBorder(0, 15, 0, 0));
        add(labels, BorderLayout.NORTH);
        add(scatterPlot, BorderLayout.CENTER);
      }

      void setPopulation(IGANsgaPopulation p, MutableTable table) {
       // if (!isCumulative) {
      //    runNumber.setText(RUN + EMOVis.this.runNumber);
       // }

        if (p != null) {
          popSize.setText(POP_SIZE + p.getMembers().length);

            IGANsgaSolution[] nis = (IGANsgaSolution[]) p.getMembers();
            int numRankZero = 0;
            for (int i = 0; i < nis.length; i++) {
              if (nis[i].getRank() == 0) {
                numRankZero++;
              }
            }
            numSolutions.setText(NUM_SOL + numRankZero);
        }
        else {
          popSize.setText(POP_SIZE);
          numSolutions.setText(NUM_SOL);
        }

        if (table != null) {
          tableModel.setPopulationTable(table);
        }
        else if(p != null){
          tableModel.setPopulation(p);
        }
      }
    }

    protected int ROW_HEIGHT = 270;
    protected int ROW_WIDTH = 270;
    protected int NUM_ROW = 2;
    protected int NUM_COL = 2;

    /**
       Shows all the Graphs in a JTable
     */
    private class ObjectiveMatrix
        extends JPanel
        implements java.io.Serializable, MouseListener, MouseMotionListener {

      ObjectiveModel tblModel;
      JTable headerColumn;
      int row;
      int col;

      public ObjectiveMatrix() {
        setup();
      }

      public void mousePressed(MouseEvent e) {}
      public void mouseClicked(MouseEvent e) {}
      public void mouseEntered(MouseEvent e) {}
      public void mouseExited(MouseEvent e) {}
      public void mouseReleased(MouseEvent e) {}
      public void mouseMoved(MouseEvent e) {}
      public void mouseDragged(MouseEvent e) {}

      void setObjectiveNames(String[] names) {
        tblModel.setObjectiveNames(names);

        JComboBox combo = new JComboBox();
        for (int i = 0; i < names.length; i++) {
          combo.addItem(names[i]);
        }
        ComboRenderer renderer = new ComboRenderer(names);
        headerColumn.setDefaultEditor(String.class,
                                      new DefaultCellEditor(combo));

        EditableHeaderTableColumn col;

        for (int i = 0; i < 2; i++) {
          tblModel.setColumnSelection(i, names[i]);
          col = (EditableHeaderTableColumn) jTable.getColumnModel().getColumn(i);
          col.setHeaderEditor(new DefaultCellEditor(combo));
          col.setHeaderValue(combo.getItemAt(i));
        }
      }

      void setup() {
        // setup the JTable

        // setup the columns for the matrix
        TableColumnModel cm = new DefaultTableColumnModel() {
          boolean first = true;
          public void addColumn(TableColumn tc) {
            if (first) {
              first = false;
              return;
            }
            tc.setMinWidth(ROW_WIDTH);
            super.addColumn(tc);
          }
        };

        // setup the columns for the row header table
        TableColumnModel rowHeaderModel = new DefaultTableColumnModel() {
          boolean first = true;
          public void addColumn(TableColumn tc) {
            if (first) {
              super.addColumn(tc);
              first = false;
            }
          }
        };

        tblModel = new ObjectiveModel();

        JComboBox combobox = new JComboBox();

        // setup the row header table
        headerColumn = new JTable(tblModel, rowHeaderModel);
        headerColumn.setRowHeight(ROW_HEIGHT);
        headerColumn.setRowSelectionAllowed(false);
        headerColumn.setColumnSelectionAllowed(false);
        headerColumn.setCellSelectionEnabled(false);
        headerColumn.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);
        // meghna
        //headerColumn.setAutoResizeMode(JTable.AUTO_RESIZE_ALL_COLUMNS);
        headerColumn.getTableHeader().setReorderingAllowed(false);
        headerColumn.createDefaultColumnsFromModel();
        headerColumn.setDefaultRenderer(String.class, new RotatedLabelRenderer());
        headerColumn.setDefaultEditor(new String().getClass(),
                                      new DefaultCellEditor(combobox));

        // setup the graph matrix
        jTable = new JTable(tblModel, cm);
        jTable.createDefaultColumnsFromModel();
        jTable.setDefaultRenderer(JPanel.class, new ComponentRenderer());
        jTable.setDefaultEditor(JPanel.class, new ComponentEditor());
        jTable.setRowHeight(ROW_HEIGHT);
        jTable.setRowSelectionAllowed(false);
        jTable.setColumnSelectionAllowed(false);
        jTable.setCellSelectionEnabled(true);
        jTable.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);

        TableColumnModel columnModel = jTable.getColumnModel();
        jTable.setTableHeader(new EditableHeader(columnModel));

        //Add mouselistener to jTable to select points in the scatterplots

        MouseListener ml = new MouseAdapter()
        {


          public void mouseReleased(MouseEvent e)
          {
          System.out.println("released ");

            row = jTable.rowAtPoint(e.getPoint());
            col = jTable.columnAtPoint(e.getPoint());

            // System.out.println("row number: " + row + " and col number: " + col + " were released.") ;
            //System.out.println(e.getX()+ "  " + e.getY());
            System.out.println("released ");
            IGAObjectiveScatterPlot scatplot = (IGAObjectiveScatterPlot) jTable.getValueAt(row,col); //new ObjectiveScatterPlot();

          //  scatplot = (ObjectiveScatterPlot) jTable.getValueAt(row,col);
          //  Point p = e.getPoint();
          //  Point p2 = SwingUtilities.convertPoint(jTable, p, scatplot);
         //   Component dispatchComponent = SwingUtilities.getDeepestComponentAt(jTable,p2.x, p2.y);
        //    System.out.println("Deepest Component : "+ dispatchComponent.toString());
        //    if (dispatchComponent == null) {
         //     System.out.println ("DISPATCH COMPONENT IS NULL");
         //   }
         //   else {
          //    MouseEvent e2 = SwingUtilities.convertMouseEvent(jTable, e, dispatchComponent);
          //    dispatchComponent.dispatchEvent(e2);
         //   }

            if (scatplot == null) {
              super.mouseReleased(e);

            } else {
              MouseEvent compEvent = SwingUtilities.convertMouseEvent(jTable, e, scatplot);
              scatplot.dispatchEvent(compEvent);

              // debug
              //scatplot.getToolTipText(compEvent);
              /////////////////
            }




          }
          public void mousePressed(MouseEvent e) {

            row = jTable.rowAtPoint(e.getPoint());
            col = jTable.columnAtPoint(e.getPoint());

            //System.out.println("pressed ");
            //System.out.println("row number: " + row + " and col number: " + col + " were pressed.") ;
            //System.out.println(e.getX()+ "  " + e.getY());
            //System.out.println("jTable.getValueAt(row,col) is : " + jTable.getValueAt(row,col)) ;
            IGAObjectiveScatterPlot scatplot = (IGAObjectiveScatterPlot) jTable.getValueAt(row,col); //new ObjectiveScatterPlot();
           // scatplot = (ObjectiveScatterPlot) jTable.getValueAt(row,col);

            if (scatplot == null) {
              super.mousePressed(e);

            } else {

              MouseEvent compEvent = SwingUtilities.convertMouseEvent(jTable, e, scatplot);
              scatplot.dispatchEvent(compEvent);
              //System.out.println("COMPEVENT : "+ compEvent);
             // debug
              // scatplot.getToolTipText(compEvent);
              ///////////
            }



          }
          public void mouseClicked(MouseEvent e) {}
          public void mouseEntered(MouseEvent e) {}
          public void mouseExited(MouseEvent e) {}

        };

        //Add mouselistener to jTable
        MouseMotionListener mml = new MouseInputAdapter()
        {
          public void mouseMoved(MouseEvent e) {}
          public void mouseDragged(MouseEvent e) {

            //System.out.println("dragged ");
            int row = jTable.rowAtPoint(e.getPoint());
            int col = jTable.columnAtPoint(e.getPoint());

            //System.out.println("row number: " + row + " and col number: " + col + " were dragged.") ;
           // System.out.println(e.getX()+ "  " + e.getY());
            IGAObjectiveScatterPlot scatplot = (IGAObjectiveScatterPlot) jTable.getValueAt(row,col); // new ObjectiveScatterPlot();
           // scatplot = (ObjectiveScatterPlot) jTable.getValueAt(row,col);

            if (scatplot == null) {
              super.mouseDragged(e);

            } else {
              MouseEvent compEvent = SwingUtilities.convertMouseEvent(jTable, e, scatplot);
              scatplot.dispatchEvent(compEvent);
              // for debug
              //scatplot.getToolTipText(compEvent);
              ///////////////
            }


          }

        };

       // jTable.addMouseListener(ml);
       // jTable.addMouseMotionListener(mml);

        String[] items = {
            "ff", "fg"};
        JComboBox combo = new JComboBox(items);

        EditableHeaderTableColumn col;
        // column 0
        col = (EditableHeaderTableColumn) jTable.getColumnModel().getColumn(0);
        col.setHeaderValue(items[0]);
        // meghna
        //col.setHeaderRenderer(renderer);
        //

        col.setHeaderEditor(new DefaultCellEditor(combo));

        // column 1
        col = (EditableHeaderTableColumn) jTable.getColumnModel().getColumn(1);
        col.setHeaderValue(items[0]);
        col.setHeaderEditor(new DefaultCellEditor(combo));


        //jTable.getTableHeader().setReorderingAllowed(false);
        //jTable.getTableHeader().setResizingAllowed(false);

        int numRows = jTable.getModel().getRowCount();
        int numColumns = jTable.getModel().getColumnCount();

        int longest = 0;
        // we know that the first column will only contain
        // JLabels...so create them and find the longest
        // preferred width
        /*JLabel tempLabel = new JLabel();
                 for (int i = 0; i < numRows; i++) {
          tempLabel.setText(
              jTable.getModel().getValueAt(i, 0).toString());
          if (tempLabel.getPreferredSize().getWidth() > longest) {
            longest = (int) tempLabel.getPreferredSize().getWidth();

          tempLabel.setText("");
                 }*/

        TableColumn column;
        // set the default column widths
        for (int i = 0; i < numColumns; i++) {
          if (i == 0) {
            column = headerColumn.getColumnModel().getColumn(i);
            column.setPreferredWidth(40);
          }
          else {
            column = jTable.getColumnModel().getColumn(i - 1);
            column.setPreferredWidth(ROW_WIDTH);
          }
        }

        // make the preferred view show four or less graphs
        /*int prefWidth;
                 int prefHeight;
                 if (numColumns < 2) {
          prefWidth = (numColumns - 1) * ROW_WIDTH;
                 }
                 else {
          prefWidth = (2) * ROW_WIDTH;
                 }
                 if (numRows < 2) {
          prefHeight = numRows * ROW_HEIGHT;
                 }
                 else {
          prefHeight = 2 * ROW_HEIGHT;
                 }*/
        jTable.setPreferredScrollableViewportSize(new Dimension(
            ROW_WIDTH * 2, ROW_HEIGHT * 2));

        // put the row headers in the viewport
        JViewport jv = new JViewport();
        jv.setView(headerColumn);
        jv.setPreferredSize(headerColumn.getPreferredSize());

        // setup the scroll pane
        JScrollPane sp = new JScrollPane(jTable);
        sp.setRowHeader(jv);
        sp.setHorizontalScrollBarPolicy(
            JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
        sp.setVerticalScrollBarPolicy(
            JScrollPane.VERTICAL_SCROLLBAR_NEVER);

        this.add(sp, BorderLayout.CENTER);
      }

      protected Table table;
      protected JTable jTable = null;

      /**
       * Renderer for a JComboBox
       */
      class ComboRenderer
          extends JComboBox
          implements TableCellRenderer {

        ComboRenderer(String[] items) {
          for (int i = 0; i < items.length; i++) {
            addItem(items[i]);
          }
        }

        public Component getTableCellRendererComponent(
            JTable table, Object value,
            boolean isSelected, boolean hasFocus,
            int row, int column) {
          setSelectedItem(value);
          return this;
        }
      }

      /**
       * A TableColumn with an editable header.
       */
      public class EditableHeaderTableColumn
          extends TableColumn {

        protected TableCellEditor headerEditor;
        protected boolean isHeaderEditable;

        public EditableHeaderTableColumn() {
          setHeaderEditor(createDefaultHeaderEditor());
          isHeaderEditable = true;
        }

        public void setHeaderEditor(TableCellEditor headerEditor) {
          this.headerEditor = headerEditor;
        }

        public TableCellEditor getHeaderEditor() {
          return headerEditor;
        }

        public void setHeaderEditable(boolean isEditable) {
          isHeaderEditable = isEditable;
        }

        public boolean isHeaderEditable() {
          return isHeaderEditable;
        }

        public void setHeaderValue(Object value) {
          super.setHeaderValue(value);
          ObjectiveMatrix.this.tblModel.setColumnSelection(this.getModelIndex() -
              1, (String) value);
        }

        public void copyValues(TableColumn base) {
          modelIndex = base.getModelIndex();
          identifier = base.getIdentifier();
          width = base.getWidth();
          minWidth = base.getMinWidth();
          setPreferredWidth(base.getPreferredWidth());
          maxWidth = base.getMaxWidth();
          headerRenderer = base.getHeaderRenderer();
          headerValue = base.getHeaderValue();
          cellRenderer = base.getCellRenderer();
          cellEditor = base.getCellEditor();
          isResizable = base.getResizable();
        }

        protected TableCellEditor createDefaultHeaderEditor() {
          return new DefaultCellEditor(new JTextField());
        }
      }

      public class EditableHeaderUI
          extends BasicTableHeaderUI {

        protected MouseInputListener createMouseInputListener() {
          return new MouseInputHandler( (EditableHeader) header);
        }

        public class MouseInputHandler
            extends BasicTableHeaderUI.MouseInputHandler {
          private Component dispatchComponent;
          protected EditableHeader header;

          public MouseInputHandler(EditableHeader header) {
            this.header = header;
          }

          private void setDispatchComponent(MouseEvent e) {
            Component editorComponent = header.getEditorComponent();
            Point p = e.getPoint();
            Point p2 = SwingUtilities.convertPoint(header, p, editorComponent);
            dispatchComponent = SwingUtilities.getDeepestComponentAt(
                editorComponent,
                p2.x, p2.y);
          }

          private boolean repostEvent(MouseEvent e) {
            if (dispatchComponent == null) {
              return false;
            }
            MouseEvent e2 = SwingUtilities.convertMouseEvent(header, e,
                dispatchComponent);
            dispatchComponent.dispatchEvent(e2);
            return true;
          }

          public void mousePressed(MouseEvent e) {
            if (!SwingUtilities.isLeftMouseButton(e)) {
              return;
            }
            super.mousePressed(e);

            if (header.getResizingColumn() == null) {
              Point p = e.getPoint();
              TableColumnModel columnModel = header.getColumnModel();
              int index = columnModel.getColumnIndexAtX(p.x);
              if (index != -1) {
                if (header.editCellAt(index, e)) {
                  setDispatchComponent(e);
                  repostEvent(e);
                }
              }
            }
          }

          public void mouseReleased(MouseEvent e) {
            super.mouseReleased(e);
            if (!SwingUtilities.isLeftMouseButton(e)) {
              return;
            }
            repostEvent(e);
            dispatchComponent = null;
          }

        }
      }

      public class EditableHeader
          extends JTableHeader
          implements CellEditorListener {
        public final int HEADER_ROW = -10;
        transient protected int editingColumn;
        transient protected TableCellEditor cellEditor;
        transient protected Component editorComp;

        public EditableHeader(TableColumnModel columnModel) {
          super(columnModel);
          setReorderingAllowed(false);
          cellEditor = null;
          recreateTableColumn(columnModel);
        }

        public void updateUI() {
          setUI(new EditableHeaderUI());
          resizeAndRepaint();
          invalidate();
        }

        protected void recreateTableColumn(TableColumnModel columnModel) {
          int n = columnModel.getColumnCount();
          EditableHeaderTableColumn[] newCols = new EditableHeaderTableColumn[n];
          TableColumn[] oldCols = new TableColumn[n];
          for (int i = 0; i < n; i++) {
            oldCols[i] = columnModel.getColumn(i);
            newCols[i] = new EditableHeaderTableColumn();
            newCols[i].copyValues(oldCols[i]);
          }
          for (int i = 0; i < n; i++) {
            columnModel.removeColumn(oldCols[i]);
          }
          for (int i = 0; i < n; i++) {
            columnModel.addColumn(newCols[i]);
          }
        }

        /*        public boolean editCellAt(int index) {
                  return editCellAt(index);
                }*/

        public boolean editCellAt(int index, EventObject e) {
          if (cellEditor != null && !cellEditor.stopCellEditing()) {
            return false;
          }
          if (!isCellEditable(index)) {
            return false;
          }
          TableCellEditor editor = getCellEditor(index);

          if (editor != null && editor.isCellEditable(e)) {
            editorComp = prepareEditor(editor, index);
            editorComp.setBounds(getHeaderRect(index));
            add(editorComp);
            editorComp.validate();
            setCellEditor(editor);
            setEditingColumn(index);
            editor.addCellEditorListener(this);

            return true;
          }
          return false;
        }

        public boolean isCellEditable(int index) {
          if (getReorderingAllowed()) {
            return false;
          }
          int columnIndex = columnModel.getColumn(index).getModelIndex();
          EditableHeaderTableColumn col = (EditableHeaderTableColumn)
              columnModel.getColumn(columnIndex - 1);
          return col.isHeaderEditable();
        }

        public TableCellEditor getCellEditor(int index) {
          int columnIndex = columnModel.getColumn(index).getModelIndex();
          EditableHeaderTableColumn col = (EditableHeaderTableColumn)
              columnModel.getColumn(columnIndex - 1);
          return col.getHeaderEditor();
        }

        public void setCellEditor(TableCellEditor newEditor) {
          TableCellEditor oldEditor = cellEditor;
          cellEditor = newEditor;

          // firePropertyChange
          if (oldEditor != null && oldEditor instanceof TableCellEditor) {
            ( (TableCellEditor) oldEditor).removeCellEditorListener( (
                CellEditorListener)this);
          }
          if (newEditor != null && newEditor instanceof TableCellEditor) {
            ( (TableCellEditor) newEditor).addCellEditorListener( (
                CellEditorListener)this);
          }
        }

        public Component prepareEditor(TableCellEditor editor, int index) {
          Object value = columnModel.getColumn(index).getHeaderValue();
          boolean isSelected = true;
          int row = HEADER_ROW;
          JTable table = getTable();
          Component comp = editor.getTableCellEditorComponent(table,
              value, isSelected, row, index);
          if (comp instanceof JComponent) {
            ( (JComponent) comp).setNextFocusableComponent(this);
          }
          return comp;
        }

        public TableCellEditor getCellEditor() {
          return cellEditor;
        }

        public Component getEditorComponent() {
          return editorComp;
        }

        public void setEditingColumn(int aColumn) {
          editingColumn = aColumn;
        }

        public int getEditingColumn() {
          return editingColumn;
        }

        public void removeEditor() {
          TableCellEditor editor = getCellEditor();
          if (editor != null) {
            editor.removeCellEditorListener(this);

            requestFocus();
            remove(editorComp);

            int index = getEditingColumn();
            Rectangle cellRect = getHeaderRect(index);

            setCellEditor(null);
            setEditingColumn( -1);
            editorComp = null;

            repaint(cellRect);
          }
        }

        public boolean isEditing() {
          return (cellEditor == null) ? false : true;
        }

        //
        // CellEditorListener
        //
        public void editingStopped(ChangeEvent e) {
          TableCellEditor editor = getCellEditor();
          if (editor != null) {
            Object value = editor.getCellEditorValue();
            int index = getEditingColumn();
            columnModel.getColumn(index).setHeaderValue(value);
            removeEditor();
          }
        }

        public void editingCanceled(ChangeEvent e) {
          removeEditor();
        }
      }
    }

    /**
       A custom cell renderer that shows an ImageIcon.  A blue border is
       painted around the selected items.
     */
    class ComponentRenderer
        extends JPanel
        implements TableCellRenderer {

      public ComponentRenderer() {
         setDoubleBuffered(false);
      }

      /**
         Set the icon and paint the border for this cell.
       */
      public Component getTableCellRendererComponent(JTable table,
          Object value, boolean isSelected, boolean hasFocus, int row,
          int column) {
        return (Component) value;
      }
    }

    class ComponentEditor
//        extends JPanel
//        implements TableCellEditor {
//	extends DefaultCellEditor {
        extends AbstractCellEditor implements TableCellEditor {
      Object val;

      public ComponentEditor() {
      }

      public Object getCellEditorValue() {
        return val;
      }

      /**
         Set the icon and paint the border for this cell.
       */
      public Component getTableCellEditorComponent(JTable table,
          Object value, boolean isSelected, int row,
          int column) {
        val = value;
        return (Component) val;
      }
    }

    class RotatedLabelRenderer extends JComponent implements TableCellRenderer {
      public RotatedLabelRenderer() {
      }

      /**
         Set the icon and paint the border for this cell.
       */
      public Component getTableCellRendererComponent(JTable table,
          Object value, boolean isSelected, boolean hasFocus, int row,
          int column) {
//        JPanel pnl = new JPanel(new BorderLayout());
        Box box = new Box(BoxLayout.Y_AXIS);
        ncsa.gui.RotatedLabel rot = new ncsa.gui.RotatedLabel((String)value);
        box.add(box.createVerticalGlue());
        box.add(rot);
        box.add(box.createVerticalGlue());
        rot.setBackground(Color.white);
//        pnl.add(rot, BorderLayout.CENTER);
//        return pnl;
        return box;
      }
    }


     /* public ComponentEditor() {
	super(new JTextField());
         setDoubleBuffered(false);
      }

      /**
         Set the icon and paint the border for this cell.
       */
  /*    public Component getTableCellEditorComponent(JTable table,
          Object value, boolean isSelected, int row,
          int column) {
        return (Component) value;
     }
    }
*/
    /**
       The table's data model.  Keeps a matrix of images that are
       displayed in the table.  The images are created from the
       Graphs.
     */
    class ObjectiveModel
        extends AbstractTableModel {

      IGAObjectiveScatterPlot[][] plots;

      int[] columnSelections;
      int[] rowSelections;
      String[] objectiveNames;
      HashMap nameToIndexMap;

      ObjectiveModel() {
        plots = new IGAObjectiveScatterPlot[2][2];
        for (int i = 0; i < 2; i++) {
          for (int j = 0; j < 2; j++) {
            plots[i][j] = new IGAObjectiveScatterPlot();
          }
        }

        columnSelections = new int[2];
        rowSelections = new int[2];
      }

      void setRowSelection(int index, String value) {
        int val;
        try {
          val = ( (Integer) nameToIndexMap.get(value)).intValue();
        }
        catch (Exception e) {
          return;
        }
        rowSelections[index] = val;

        // now, for all the plots in this row, update the objectives
        for (int i = 0; i < 2; i++) {
          plots[index][i].setObjectives(val, columnSelections[i]);
        }
        fireTableDataChanged();
      }

      void setColumnSelection(int index, String value) {
        int val;
        try {
          val = ( (Integer) nameToIndexMap.get(value)).intValue();
        }
        catch (Exception e) {
          return;
        }
        columnSelections[index] = val;

        // now, for all the plots in this column, update the objectives
        for (int i = 0; i < 2; i++) {
          plots[i][index].setObjectives(rowSelections[i], val);
        }
        fireTableDataChanged();
      }

      void setObjectiveNames(String[] names) {
        objectiveNames = names;
        nameToIndexMap = new HashMap(names.length);
        for (int i = 0; i < names.length; i++) {
          nameToIndexMap.put(names[i], new Integer(i));

        }
        for (int i = 0; i < 2; i++) {
          setRowSelection(i, objectiveNames[i]);
        }
      }

      void setPopulationTable(MutableTable popTable) {
        for (int i = 0; i < plots.length; i++) {
          for (int j = 0; j < plots[i].length; j++) {
            ( (IGAObjectiveScatterPlot) plots[i][j]).setTable(popTable);
            ( (IGAObjectiveScatterPlot) plots[i][j]).setObjectives(rowSelections[i],
                columnSelections[j]);
          }
        }
        fireTableDataChanged();
      }

      void setPopulation(IGANsgaPopulation p) {
        for (int i = 0; i < plots.length; i++) {
          for (int j = 0; j < plots[i].length; j++) {
            ( (IGAObjectiveScatterPlot) plots[i][j]).setPopulation(p);
            ( (IGAObjectiveScatterPlot) plots[i][j]).setObjectives(rowSelections[i],
                columnSelections[j]);
          }
        }
        //this.fireTableDataChanged();
        fireTableDataChanged();
      }

      /**
         There is one more column than there are input features.
         The first column shows the output variables.
       */
      public int getColumnCount() {
        return NUM_COL + 1;
      }

      /**
         There are the same number of rows as output features.
       */
      public int getRowCount() {
        //return outputs.length;
        return NUM_ROW;
      }

      public String getColumnName(int col) {
        if (col == 0) {
          return "";
        }
        else {
          //return et.getColumnLabel(inputs[col-1]);
          return "col";
        }
      }

      public Object getValueAt(int row, int col) {
        if (col == 0) {
          if (objectiveNames == null) {
            return "";
          }
          else {
            return objectiveNames[rowSelections[row]];
          }
        }
        else {
          return plots[row][col - 1];
        }
      }

      public void setValueAt(Object value, int row, int col) {
        if (col == 0) {
          //rowheaders[row] = (String) value;
          //ScatterPlotWidget.this.setup();
          //ScatterPlotWidget.this.revalidate();
          setRowSelection(row, (String) value);
        }
      }

      /**
         This must be overridden so that our custom cell renderer is
         used.
       */
      public Class getColumnClass(int c) {
        return getValueAt(0, c).getClass();
      }

      public boolean isCellEditable(int row, int col) {
        if (col == 0) {
          return true;
        }
        return true;
      }
    } // Objective Model
  }//IGAScatterPlotView
}//IGAObjectiveScatterPlotWindow
