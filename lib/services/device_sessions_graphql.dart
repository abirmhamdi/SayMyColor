import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DeviceSessionsGraphQLPage extends StatelessWidget {
  const DeviceSessionsGraphQLPage({super.key});

  final String query = """
    query {
      allDeviceSessions {
        id
        deviceName
        deviceType
        expiresAt
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Sessions (GraphQL)")),
      body: Query(
        options: QueryOptions(
          document: gql(query),
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text("Erreur: ${result.exception.toString()}"));
          }

          final List sessions = result.data?['allDeviceSessions'] ?? [];

          if (sessions.isEmpty) {
            return const Center(child: Text("Aucune session trouvée."));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                leading: const Icon(Icons.devices),
                title: Text(session['deviceName'] ?? 'Sans nom'),
                subtitle: Text("Expire: ${session['expiresAt']}"),
              );
            },
          );
        },
      ),
    );
  }
}