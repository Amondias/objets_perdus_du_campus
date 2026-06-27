import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../providers/items_provider.dart';
import 'item_detail_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itemsProvider = context.watch<ItemsProvider>();
    final campusCenter = LatLng(AppConfig.defaultLatitude, AppConfig.defaultLongitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte du Campus'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: campusCenter,
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.objets_perdus_du_campus',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          MarkerLayer(
            markers: itemsProvider.filteredItems.map((item) {
              return Marker(
                point: LatLng(item.location.latitude, item.location.longitude),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.isLost ? AppConfig.accentLost : AppConfig.accentFound,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Icon(
                      AppConfig.getCategoryById(item.category)?['icon'] ?? Icons.category,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
