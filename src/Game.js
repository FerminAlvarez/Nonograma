import React from 'react';
import PengineClient from './PengineClient';
import Board from './Board';

class Game extends React.Component {

  pengine;

  constructor(props) {
    super(props);
    this.state = {
      grid: null,
      rowClues: null,
      colClues: null,
      waiting: false,
      contenido:"X",
      rowStates:[],
      colStates:[],
      finish: false,
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.pengine = new PengineClient(this.handlePengineCreate);
    this.changeMode = this.changeMode.bind(this);
  }

  // Preguntar si arranca bien ...
  
  
  handlePengineCreate() {
    const queryS = 'init(PistasFilas, PistasColumnas, Grilla)';
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response['Grilla'],
          rowClues: response['PistasFilas'],
          colClues: response['PistasColumnas'],
        });

        var rowStatesInit = new Array(response['PistasFilas'].length);
        console.log(rowStatesInit.length);
        for(var i = 0; i <rowStatesInit.length; i++){
          rowStatesInit[i] = false;
        }
        var colStatesInit = new Array(response['PistasColumnas'].length);
        for(i = 0; i <colStatesInit.length; i++){
          colStatesInit[i]  = false;
        }

        this.setState({
          rowStates: rowStatesInit,
          colStates: colStatesInit,

        });

      }


      
    });
  }

  handleClick(i, j) {
    // No action on click if we are waiting.
    if (this.state.waiting) {
      return;
    }
    // Build Prolog query to make the move, which will look as follows:
    // put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)

    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Remove quotes for variables.
    const rowClues = JSON.stringify(this.state.rowClues);
    const colClues = JSON.stringify(this.state.colClues);
    const contenido = JSON.stringify(this.state.contenido);
    
    const queryS = 'put(' + contenido + ', [' + i + ',' + j + ']' + ',' + rowClues + ',' + colClues+ ',' + squaresS + ', GrillaRes, FilaSat, ColSat)';


    this.setState({
      waiting: true
    });
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        const rowStatesAux = this.state.rowStates;
        rowStatesAux[i] = response['FilaSat'] === 1 ? true : false;

        const colStatesAux = this.state.colStates;
        colStatesAux[j] = response['ColSat'] === 1 ? true : false;
        this.checkWin();
        this.setState({
          grid: response['GrillaRes'],
          rowStates : rowStatesAux,
          colStates : colStatesAux,
          waiting: false,
        });
        
      } else {
        this.setState({
          waiting: false
        });
      }
    });
  }


  

  render() {
    if (this.state.grid === null) {
      return null;
    }
    const statusText = this.state.finish ? 'Congrats bro' : 'Keep playing!';
   
    return (
      <div className="game">
        <Board
          grid={this.state.grid}
          rowClues={this.state.rowClues}
          colClues={this.state.colClues}
          onClick={(i, j) => this.handleClick(i,j)}
          rowStates = {this.state.rowStates}
          colStates = {this.state.colStates}
        />
        <div className="gameInfo">
          {statusText}
          <div class="mid">
            <label class="rocker rocker-small">
              <input type="checkbox" onClick={this.changeMode}></input>
              <span class="switch-left">#</span>
              <span class="switch-right">X</span>
            </label>
        </div>
        </div>
        
      </div>
    );
    
  }
  changeMode() {
    var mode = this.state.contenido === "X" ? "#" : "X";
    this.setState({
        contenido:mode,
    });
  }

  checkWin(){
    var indexRow = 0;
    var rowSat = true;
    
    var indexCol = 0;
    var colSat = true;


    while (rowSat && indexRow < this.state.rowStates.length) {
      rowSat  = this.state.rowStates[indexRow];
      indexRow++;
    }


    while (colSat && indexCol < this.state.colStates.length) {
      colSat  = this.state.colStates[indexCol];
      indexCol++;
    }


    console.log("satisface row:" + rowSat + "col:" + colSat);


    this.setState({
      finish: colSat && rowSat,
    });
  }
}



export default Game;
