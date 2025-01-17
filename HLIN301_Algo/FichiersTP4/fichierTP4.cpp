#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
//#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "progListeSC.h"
#include "fichierTP4.h"
using namespace std;


ArbreBin creerArbreBin(int e, ArbreBin G, ArbreBin D){
  /* Res : renvoie une ArbreBin dont la racine vaut e, le sag G et le sad D   */
  ArbreBin A = new NoeudSC;
  A->info=e;  A->sag=G;  A->sad=D;
  return A;}
  
void codageABdot(ofstream& fichier, ArbreBin A){
  if (A != NULL){ 
    fichier << (long) A << " [label=\""  << A->info << "\" ] ;\n";
    if (A->sag != NULL) {
      fichier << (long)A << " -> " << (long)(A->sag) <<  " [color=\"red\",label=\"g\" ] ;\n";
      codageABdot(fichier,A->sag);} 
    if (A->sad != NULL) {
      fichier << (long)A << " -> " << (long)(A->sad) << " [color=\"blue\",label=\"d\" ] ;\n";
      codageABdot(fichier,A->sad);}
  }
  return;}
    

void dessinerAB(ArbreBin A, const char * nomFic, string titre){
  ofstream f(nomFic);
  if (!f.is_open()){
   cout << "Impossible d'ouvrir le fichier en �criture !" << endl;
  }
  else {
    f<< "digraph G { label = \""<< titre << "\" \n";
    codageABdot(f,A);
    f << "\n }\n" ;
    f.close();}
  return;}


/* A COMPLETER */
int sommeNoeuds(ArbreBin A){
  /* renvoie la somme des etiquettes des noeuds de l arbre binaire A */

  if(A==NULL){
    return 0;
  }else{
    return A->info + sommeNoeuds(A->sag) + sommeNoeuds(A->sad);
  }
  return 0;}

int profMinFeuille(ArbreBin A){
  /* renvoie la profondeur minimum des feuilles de l'arbre A ; A est non vide */
  assert(A!=NULL);

  if(A->sag == NULL && A->sad==NULL){
    return 0;
  }else{
    return 1+ min(profMinFeuille(A->sag),profMinFeuille(A->sad));
  }
  
  return 0;}
    
ListeSC parcoursInfixe(ArbreBin A){
  /* renvoie la liste composee des etiquettes des noeuds de l'arbre A ordonn�e
     selon l'ordre infixe */

  ListeSC L = NULL;
  if(A->sag==NULL){
    insererFinLSC(L,A->info);
    return L;
  }
  L = concatLSC(L,parcoursInfixe(A->sag));
  insererFinLSC(L,A->info);
  L = concatLSC(L,parcoursInfixe(A->sad));
  return L;
}

void effeuiller(ArbreBin& A){
  /* modifie l'arbre A en supprimant ses feuilles */
  if(A == NULL){
    return;
  }
  else if(A->sag==NULL && A->sad==NULL){
    A = NULL;
  }else{
    effeuiller(A->sag);
    effeuiller(A->sad);
  }
}

void tailler(ArbreBin& A, int p){
  /* modifie l'arbre A, en supprimant ses noeuds de profondeur au moins p ; p est un entier positif ou nul */
  if(A==NULL) return;
  tailler(A->sag,p-1);
  tailler(A->sad,p-1);
  if(A->sag == NULL && A->sad==NULL && p<=0){
    A = NULL;
  } 
}

void tronconner(ArbreBin& A){
  /* modifie l'arbre A, en supprimant les noeuds dont un seul sous-arbre est vide */

  if(A == NULL) return;
  if(A->sag==NULL && A->sad==NULL) return;
  if(A->sag!=NULL){
    if(A->sag->sag == NULL || A->sag->sad == NULL){
      if(A->sag->sag == NULL && A->sag->sad != NULL){
	A->sag = A->sag->sad;
      }else if(A->sag->sad == NULL && A->sag->sag != NULL){
	A->sag = A->sag->sag;
      }
    }
  }
  if(A->sad!=NULL){
    if(A->sad->sag == NULL || A->sad->sad == NULL){
      if(A->sad->sag == NULL && A->sad->sad != NULL){
	A->sad = A->sad->sad;
      }else if(A->sad->sad == NULL && A->sad->sag != NULL){
	A->sad = A->sad->sag;
      }
    }
  }
  tronconner(A->sag);
  tronconner(A->sad);
}

ArbreBin genereAB(int n){

  if(n<=1){
    return creerArbreBin(n,NULL,NULL);
  }else{
    return creerArbreBin(n,genereAB(n-(n/2)),genereAB(n/2));
  }
}  


int estParfait(ArbreBin A){
  // V�rifie si A est un arbre binaire parfait
  
  if(A==NULL){
    return 0;
  }else{
    if(estParfait(A->sag)==estParfait(A->sad)){
      return estParfait(A->sag)+1;
    }else{
      return 0;
    }
  }
}

