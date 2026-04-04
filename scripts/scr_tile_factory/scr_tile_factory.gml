function add_property(_sprite, _name, _price, _rent){
	return new Tile(
		TileType.Property, _sprite, _name, _price, _rent
	)
}


// Non Props
function add_start(_sprite, _name){
	return new Tile(TileType.Start, _sprite, _name)
}

function add_fate(_sprite, _name) {
    return new Tile(TileType.Fate,   _sprite, _name);
}
function add_jail(_sprite, _name) {
    return new Tile(TileType.Jail,   _sprite, _name);
}
function add_casino(_sprite, _name) {
    return new Tile(TileType.Casino,  _sprite, _name);
}
function add_market(_sprite, _name) {
    return new Tile(TileType.Market,  _sprite, _name);
}