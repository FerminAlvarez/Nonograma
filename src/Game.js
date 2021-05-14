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
      contenido:"X"
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.pengine = new PengineClient(this.handlePengineCreate);
    this.changeModeToVoid = this.changeModeToVoid.bind(this);
    this.changeModeToX = this.changeModeToX.bind(this);
  }

  
  
  

  handlePengineCreate() {
    const queryS = 'init(PistasFilas, PistasColumnas, Grilla)';
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response['Grilla'],
          rowClues: response['PistasFilas'],
          colClues: response['PistasColumnas'],
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

    console.log('put(' + contenido + ', [' + i + ',' + j + ']' + ',' + rowClues + ',' + colClues+ ',' + squaresS + ', GrillaRes, FilaSat, ColSat)');
    const queryS = 'put(' + contenido + ', [' + i + ',' + j + ']' + ',' + rowClues + ',' + colClues+ ',' + squaresS + ', GrillaRes, FilaSat, ColSat)';

    


    this.setState({
      waiting: true
    });
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response['GrillaRes'],
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
    const statusText = 'Keep playing!';
   
    return (
      <div className="game">
        <Board
          grid={this.state.grid}
          rowClues={this.state.rowClues}
          colClues={this.state.colClues}
          onClick={(i, j) => this.handleClick(i,j)}
        />
        <div className="gameInfo">
          {statusText}
        </div>
        
        <div>  
            <button id="botonX" class="buttonX" onClick={this.changeModeToX}>X</button>
            <button id="boton#" class="buttonVoid" onClick={this.changeModeToVoid}>#</button>
        </div>
      </div>

      
    );
    
  }

  changeModeToX() {
    console.log("Cambiamos a X"); 
    this.setState({
         contenido:"X",
    });
  } 

  changeModeToVoid() {
    console.log("Cambiamos a #");
    this.setState({
      contenido:"#",
    });
  } 


  

}



export default Game;
