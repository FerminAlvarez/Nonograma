import React from 'react';

class Square extends React.Component {
    render() {
        return (
            <button className={"squareSolution" + (this.props.value === "#" ? "-painted" : "")}></button>
                
        );
    }
}

export default Square;