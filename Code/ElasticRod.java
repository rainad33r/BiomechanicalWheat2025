package artisynth.models.testspace;

//java colour and math packages
import java.awt.Color;
import java.lang.Math;

//Import core mechanical Models
import artisynth.core.mechmodels.*;
import artisynth.core.probes.NumericInputProbe;
import artisynth.core.workspace.RootModel;
import artisynth.core.femmodels.FemModel3d;
import artisynth.core.gui.*;

//import artisynth.core.gui.ControlPanel;

//Import Geometry and transformation packages
import maspack.geometry.PolygonalMesh;
//import maspack.geometry.MeshBase;
import maspack.geometry.MeshFactory;

import maspack.matrix.RigidTransform3d;
import maspack.properties.PropertyList; //will get used for control panel
import maspack.render.RenderProps;

//PointForce
import maspack.matrix.Point3d;
import maspack.matrix.Vector3d;
import maspack.render.Renderer;


public class ElasticRod extends RootModel {

        MechModel mymech = null;  // Initialize the mechanical model
        FemModel3d myfem = null;  // Initializes the finite element model
        PointForce pf = null;     // Initializes point force to be used universally
 
        //Stem material properties
        static double DEFAULTSTIFF = 500000;
        double StiffnessI = DEFAULTSTIFF;
        static double DEFAULTDAMP = 0.1;
        double DampingI = DEFAULTDAMP;
        
        static double DEFAULTFORCE = 10.0;
        
        public static PropertyList myProps = 
                new PropertyList (ElasticRod.class, RootModel.class);
                
        static {
                myProps.add(
                        "RodStiffness", "Stiffness of the Stem", DEFAULTSTIFF);
                myProps.add(
                        "RodDamping","Damping of the Stem", DEFAULTDAMP);
                myProps.add (
                        "RodForce", "Point Force affecting the stem", DEFAULTFORCE);
                }
        
        @Override
        public PropertyList getAllPropertyInfo() {
           return myProps;
        }

        //function to build beams
        EBBeamBody createRod(
        MechModel mech, double len, double rad, RigidTransform3d TRW){
                
                //Create mesh to build internal rod component
                PolygonalMesh mesh;
                mesh = MeshFactory.createCylinder (rad, len, /** Slices = */ 20);
                mesh.transform (new RigidTransform3d (len / 2, 0, 0, 0, Math.PI /2, 0));
                
                EBBeamBody body = 
                        new EBBeamBody (len, rad, /*density =*/ 1, StiffnessI);
                body.setMassDamping(getRodDamping()); 
                
                RenderProps.setPointRadius (mech, rad);
                RenderProps.setFaceColor (body, new Color (245/255f, 222/255f, 179/255f));
                
                //Change for position
                body.setPose (TRW); 
                mech.addRigidBody(body);
                return body;            
        }
        

        //This should just be a rigid body at this point
        void createHead(
           MechModel mech, FemModel3d fem, double len, double damping, 
           RigidTransform3d TRW) {
           
           
           
        }
        
        //Creates an anchor for the rod
        void anchoR(
                MechModel mech, EBBeamBody b0, RigidBody r1, RigidTransform3d TRW){
                mech.addBodyConnector (new SolidJoint(b0, TRW));
                }

        //main function to build out of root model
        public void build (String[] args) {
        
           //Create mech model that encapsulates everything
           mymech = new MechModel("mymech");
           addModel (mymech);
                                
           double rad = 0.1; //radius of rod
           double len = 15; //length of rod 
                
           //Create rigid box to hold stem --> green box
           RigidBody plate = RigidBody.createBox ( "plate", 5, 5, 1, /*density=*/1000.0);
           plate.setPose (new RigidTransform3d (0, 0, 0));
           mymech.addRigidBody (plate);
           plate.setDynamic (false); //Block not affected by gravity 
           RenderProps.setFaceColor (plate, new Color (0, 128/255f, 0));

           //Orient the beam so it is upright and build
           RigidTransform3d TDW = new RigidTransform3d(
                        0, 0, 0, Math.toRadians(-90), Math.toRadians (-90.0), 0);
           EBBeamBody rod1 = createRod (mymech, len, rad, TDW);
           //Anchor the beam at the bottom
           anchoR (mymech, rod1, plate, TDW);
                
                
           //FRAME MARKER IS FINE, z doesn't change though**
           FrameMarker m = new FrameMarker ("ee");
           mymech.addFrameMarker (m, rod1, 
                                   new Point3d(len, 0, 0));
           
           RenderProps.setPointStyle (m, Renderer.PointStyle.SPHERE);
           RenderProps.setPointColor (m, Color.ORANGE);
           RenderProps.setPointRadius (m, 0.5);

//           double setMag = DEFAULTFORCE;
           Vector3d Fext = new Vector3d (-1, 0, 0);
           pf = new PointForce (Fext, m);
           pf.setMagnitude(getRodForce());
           pf.setAxisLength (0.1);
           pf.setForceLengthRatio(0.5);
           pf.setAxisRadiusRatio (1);
           RenderProps.setVisible (pf,  false);
           mymech.addForceEffector (pf);

           //addControlPanel(createControlPanel());
           ControlPanel panel = new ControlPanel("CONTROL PANEL");
           panel.addWidget (this, "RodStiffness");
           panel.addWidget (this, "RodDamping");
           panel.addWidget (this, "RodForce");
           addControlPanel(panel);
        
           NumericInputProbe eprobe =
              new NumericInputProbe (this, "RodForce", 0, 10.0);
           eprobe.addData (
              new double[] { 1, 0,
                             0.1, 10,
                             },
                  NumericInputProbe.EXPLICIT_TIME);
           addInputProbe (eprobe);
        }
        
        ControlPanel createControlPanel() {
           ControlPanel panel = new ControlPanel("CONTROL PANEL");
           panel.addWidget (this, "RodStiffness");
           panel.addWidget (this, "RodDamping");
           //panel.addWidget (getforceEffector.pf);
           return  panel;
        }
        
         private void initMembersIfNecessary () {
              if (mymech == null) {
                 mymech = (MechModel)findComponent ("models/mech");
              }
           }
         
         public void setRodStiffness (double E) {
              if (E != StiffnessI) {
                 initMembersIfNecessary();
                 StiffnessI = E;
                 for (RigidBody body : mymech.rigidBodies()) {
                    if (body instanceof EBBeamBody) {
                       ((EBBeamBody)body).setStiffness (E);
                    }
                 }
              }
           }
           
           public double getRodStiffness() {
              return StiffnessI;
           }

           public void setRodDamping (double d) {
              if (d != DampingI) {
                 initMembersIfNecessary();
                 DampingI = d;
                 for (RigidBody body : mymech.rigidBodies()) {
                    if (body instanceof EBBeamBody) {
                       ((EBBeamBody)body).setMassDamping (d);
                    }
                 }
              }
           }
           
           public double getRodDamping() {
              return DampingI;
           }
           
           public double getRodForce() {
              initMembersIfNecessary();
              //needs to return element of point force to be force
              return pf.getMagnitude();
           }
           
//         //Don't know what this does, but if I move it this breaks
           public void setRodForce(double DEFAULTFORCE) {
              initMembersIfNecessary();
              //need to find a way to separate forces from model
              pf.setMagnitude (DEFAULTFORCE);
           }  
           
           /*SHIT DON'T WORK*/
           public boolean isTransparent()
           {
              return true;
           }
}