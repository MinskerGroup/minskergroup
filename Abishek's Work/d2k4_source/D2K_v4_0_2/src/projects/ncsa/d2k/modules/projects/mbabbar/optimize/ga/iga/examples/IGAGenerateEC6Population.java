package ncsa.d2k.modules.projects.mbabbar.optimize.ga.iga.examples;

import ncsa.d2k.modules.core.optimize.ga.*;
import ncsa.d2k.modules.core.optimize.ga.emo.*;
import ncsa.d2k.modules.core.optimize.ga.nsga.*;
import ncsa.d2k.modules.core.optimize.util.*;
import ncsa.d2k.core.modules.*;
import ncsa.d2k.modules.projects.mbabbar.optimize.ga.iga.*;
import java.io.Serializable;

/**
		CrossoverModule.java

*/
public class IGAGenerateEC6Population extends PopulationPrep  {
	public IGAGenerateEC6Population () {
	}
        // Seed for random number generator
        long randomSeed = 0;

        // get random number seed
        public long getRandomSeed (){
          return randomSeed;
        }

        // set random number seed
        public void setRandomSeed (long seed){
          randomSeed = seed;
        }

	/**
		This method returns the description of the module.

		@return the description of the module.
	*/
	public String getModuleInfo () {
		return "<html>  <head>      </head>  <body>    This module sets up the initial population, and will set all the fields of     the population that are used to steer the genetic algorithm.  </body></html>";
	}

	/**
		Create the initial population. In this case we have chosen to override the doit method,
		though it was probably not necessary

		@param outV the array to contain output object.
	*/
	public void doit () throws Exception {

		// First define the binary range, in this case 8 bits.
		int numGenes = 1;
		DoubleRange [] xyz = new DoubleRange [10];
		xyz [0] = new DoubleRange ("x1",1.0, 0.0);
		xyz [1] = new DoubleRange ("x2",1.0, 0.0);
		xyz [2] = new DoubleRange ("x3",1.0, 0.0);
		xyz [3] = new DoubleRange ("x4",1.0, 0.0);
		xyz [4] = new DoubleRange ("x5",1.0, 0.0);
		xyz [5] = new DoubleRange ("x6",1.0, 0.0);
		xyz [6] = new DoubleRange ("x7",1.0, 0.0);
		xyz [7] = new DoubleRange ("x8",1.0, 0.0);
		xyz [8] = new DoubleRange ("x9",1.0, 0.0);
		xyz [9] = new DoubleRange ("x10",1.0, 0.0);


		// the objective constraints is a property of the problem. However, as a parameter
		// of this module, we can either minimize or maximize by swapping the values
                boolean [] qualObjFlags = new boolean[3];
                qualObjFlags[0] = false;
                qualObjFlags[1] = false;
                qualObjFlags[2] = true;
		ObjectiveConstraints oc [] = new ObjectiveConstraints [3];
		oc[0] = ObjectiveConstraintsFactory.getObjectiveConstraints ("f1",
				this.getBestFitness (), this.getWorstFitness ());
		oc[1] = ObjectiveConstraintsFactory.getObjectiveConstraints ("f2",
				this.getBestFitness (), this.getWorstFitness ());
                oc[2] = ObjectiveConstraintsFactory.getObjectiveConstraints ("human f3",
				this.getBestFitness (), this.getWorstFitness ());
		IGANsgaPopulation pop = new IGANsgaPopulation (xyz, oc, this.getPopulationSize (), this.getTargetFitness (), this.randomSeed);
		pop.setMaxGenerations (this.maxGenerations);
                pop.setIgaQualObj(qualObjFlags);

                // initialize rank flags that indicate whether an individual has been ranked or not.
                for(int i = 0; i< this.getPopulationSize(); i++){
                  ((IGANsgaSolution)pop.getMember(i)).setRankedIndivFlag(false);
                }
		this.pushOutput (pop, 0);
	}

	/**
	 * Return the human readable name of the module.
	 * @return the human readable name of the module.
	 */
	public String getModuleName() {
		return "IGA:GenerateEC6Population";
	}

	/**
	 * Return the human readable name of the indexed input.
	 * @param index the index of the input.
	 * @return the human readable name of the indexed input.
	 */
	public String getInputName(int index) {
		switch(index) {
			default: return "NO SUCH INPUT!";
		}
	}

	/**
	 * Return the human readable name of the indexed output.
	 * @param index the index of the output.
	 * @return the human readable name of the indexed output.
	 */
	public String getOutputName(int index) {
		switch(index) {
			case 0:
				return "Population";
			default: return "NO SUCH OUTPUT!";
		}
	}
}
