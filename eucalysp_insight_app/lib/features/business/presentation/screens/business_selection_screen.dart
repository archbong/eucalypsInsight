// lib/features/business/presentation/screens/business_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/business/domain/entities/business.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart'; // To get userId from AuthCubit
import 'package:eucalysp_insight_app/features/auth/bloc/auth_state.dart';

class BusinessSelectionScreen extends StatelessWidget {
  const BusinessSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch businesses when the screen is first built or if the AuthCubit changes to Authenticated.
    // We use a BlocListener to react to AuthState changes.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Business'),
        automaticallyImplyLeading:
            false, // Prevent back button on this critical screen
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthCubit>().logout();
              context
                  .read<BusinessCubit>()
                  .clearSelectedBusiness(); // Clear business on logout
            },
          ),
        ],
      ),
      body: BlocConsumer<BusinessCubit, BusinessState>(
        listener: (context, state) {
          if (state is BusinessLoaded && state.selectedBusiness != null) {
            // If a business is selected, navigate to the dashboard
            context.go('/dashboard');
          } else if (state is BusinessError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          // Get userId from AuthCubit to pass to BusinessCubit
          final authState = context.watch<AuthCubit>().state;
          String? userId;
          if (authState is Authenticated) {
            userId = authState.userId;
            // Trigger fetch if in initial state and userId is available
            if (state is BusinessInitial) {
              context.read<BusinessCubit>().fetchBusinesses(userId);
            }
          } else {
            // Should not happen if redirect logic works, but handle gracefully
            return const Center(child: Text('Authentication required.'));
          }

          if (state is BusinessLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BusinessLoaded) {
            if (state.availableBusinesses.isEmpty) {
              return const Center(
                child: Text('No businesses found for your account.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.availableBusinesses.length,
              itemBuilder: (context, index) {
                final business = state.availableBusinesses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(business.name),
                    subtitle: Text(business.description),
                    onTap: () {
                      context.read<BusinessCubit>().selectBusiness(business);
                    },
                    selected: state.selectedBusiness?.id == business.id,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ),
                );
              },
            );
          } else if (state is BusinessError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (userId != null) {
                        context.read<BusinessCubit>().fetchBusinesses(userId);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Unknown Business State'));
        },
      ),
    );
  }
}
